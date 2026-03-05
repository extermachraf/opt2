const fs = require('fs');
const XLSX = require('./node_modules/xlsx');

const url = 'https://jnukglbwreegcluvwgad.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpudWtnbGJ3cmVlZ2NsdXZ3Z2FkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5MTgyMTksImV4cCI6MjA4NjI3ODIxOX0.5LS97w7_UiiNj86D3yau9VFiy0vNWiKsG0wwb5OWb-I';

// Load BDA nutrition from Excel with base code matching
const bdaWb = XLSX.readFile('../BDA_Banca Dati Alimentari_V1.2022.xlsx');
const bdaWs = bdaWb.Sheets['BDA-2022'];
const bdaData = XLSX.utils.sheet_to_json(bdaWs, { header: 1 });

const bdaMap = {};
const bdaMapBase = {};
for (let i = 3; i < bdaData.length; i++) {
  const row = bdaData[i];
  const code = (row[1] || '').toString();
  if (code) {
    // In BDA, negative values (e.g. -3) mean "not available / trace" -> treat as 0
    const p = (v) => { const x = parseFloat(v); return (isNaN(x) || x < 0) ? 0 : x; };
    const n = { kcal: p(row[7]), protein: p(row[9]), fat: p(row[12]), carbs: p(row[16]), fiber: p(row[19]) };
    bdaMap[code] = n;
    const base = code.replace(/_[12]$/, '');
    if (!bdaMapBase[base]) bdaMapBase[base] = n;
  }
}
function getBda(code) { return bdaMap[code] || bdaMapBase[code.replace(/_[12]$/, '')] || null; }
function round2(n) { return Math.round(n * 100) / 100; }
function esc(s) { return (s || '').replace(/'/g, "''"); }

// Parse Ricette Excel to get BDA codes per ingredient
const wb = XLSX.readFile('../Ricette per APP_v2.xlsx');
const excelRecipes = {}; // title -> [{name, weight, bdaCode}]

wb.SheetNames.slice(0, 2).forEach(sheetName => {
  const ws = wb.Sheets[sheetName];
  const data = XLSX.utils.sheet_to_json(ws, { header: 1 });
  let current = null;
  data.forEach(row => {
    const col0 = (row[0] || '').toString().trim();
    if (col0 && !row[1] && !row[3] && !col0.includes('Analisi') && col0 !== 'PESI' && col0 !== 'Quantita') {
      current = col0;
      if (!excelRecipes[current]) excelRecipes[current] = [];
      return;
    }
    if (!current || !row[1] || !row[3]) return;
    excelRecipes[current].push({
      name: (row[4] || col0).toString().trim(),
      weight: round2(parseFloat(row[1])),
      bdaCode: row[3].toString()
    });
  });
});

async function fetchAll(endpoint) {
  let all = [], offset = 0;
  while (true) {
    const resp = await fetch(url + endpoint + '&limit=500&offset=' + offset, {
      headers: { 'apikey': key, 'Authorization': 'Bearer ' + key }
    });
    const data = await resp.json();
    if (!Array.isArray(data) || data.length === 0) break;
    all = all.concat(data);
    if (data.length < 500) break;
    offset += 500;
  }
  return all;
}

async function main() {
  // Fetch all recipes and their ingredients
  const recipes = await fetchAll('/rest/v1/recipes?select=id,title');
  console.log('DB recipes:', recipes.length);

  const recipeMap = {}; // title -> id
  recipes.forEach(r => { recipeMap[r.title] = r.id; });

  const ingredients = await fetchAll('/rest/v1/recipe_ingredients?select=id,recipe_id,ingredient_name,weight_grams,calories,protein_g,carbs_g,fat_g,fiber_g');
  console.log('DB ingredients:', ingredients.length);

  // Group DB ingredients by recipe_id
  const ingByRecipe = {};
  ingredients.forEach(i => {
    if (!ingByRecipe[i.recipe_id]) ingByRecipe[i.recipe_id] = [];
    ingByRecipe[i.recipe_id].push(i);
  });

  // Find ingredients with zero macros but non-zero calories -> likely broken
  const updates = [];
  const recipeIdsToFix = new Set();

  Object.entries(excelRecipes).forEach(([title, excelIngs]) => {
    const recipeId = recipeMap[title];
    if (!recipeId) return;
    const dbIngs = ingByRecipe[recipeId] || [];

    excelIngs.forEach(exIng => {
      const bda = getBda(exIng.bdaCode);
      if (!bda) return;

      // Find matching DB ingredient by name + weight
      const match = dbIngs.find(d =>
        d.ingredient_name === exIng.name && Math.abs(d.weight_grams - exIng.weight) < 0.1
      );
      if (!match) return;

      // Check if macros are wrong (all zero but should have values)
      const correctP = round2(exIng.weight * bda.protein / 100);
      const correctC = round2(exIng.weight * bda.carbs / 100);
      const correctF = round2(exIng.weight * bda.fat / 100);
      const correctFi = round2(exIng.weight * bda.fiber / 100);
      const correctCal = round2(exIng.weight * bda.kcal / 100);

      if (Math.abs(match.protein_g - correctP) > 0.01 || Math.abs(match.carbs_g - correctC) > 0.01 ||
          Math.abs(match.fat_g - correctF) > 0.01 || Math.abs(match.fiber_g - correctFi) > 0.01 ||
          Math.abs(match.calories - correctCal) > 0.5) {
        updates.push({ id: match.id, cal: correctCal, p: correctP, c: correctC, f: correctF, fi: correctFi, name: exIng.name, recipe: title });
        recipeIdsToFix.add(recipeId);
      }
    });
  });

  console.log('\nIngredients to fix:', updates.length);
  console.log('Recipes affected:', recipeIdsToFix.size);

  // Generate SQL
  let sql = `-- Fix macros for ingredients that were imported with zero protein/carbs/fat/fiber\n-- Due to BDA code _1/_2 version mismatch\n-- Generated: ${new Date().toISOString()}\n\nBEGIN;\n\n`;

  updates.forEach(u => {
    sql += `UPDATE recipe_ingredients SET calories = ${u.cal}, protein_g = ${u.p}, carbs_g = ${u.c}, fat_g = ${u.f}, fiber_g = ${u.fi} WHERE id = '${u.id}';\n`;
  });

  // Also fix recipe totals for affected recipes
  sql += '\n-- Recalculate recipe totals\n';
  for (const recipeId of recipeIdsToFix) {
    sql += `UPDATE recipes SET total_calories = (SELECT ROUND(SUM(calories)) FROM recipe_ingredients WHERE recipe_id = '${recipeId}'), total_protein_g = (SELECT ROUND(SUM(protein_g)::numeric, 2) FROM recipe_ingredients WHERE recipe_id = '${recipeId}'), total_carbs_g = (SELECT ROUND(SUM(carbs_g)::numeric, 2) FROM recipe_ingredients WHERE recipe_id = '${recipeId}'), total_fat_g = (SELECT ROUND(SUM(fat_g)::numeric, 2) FROM recipe_ingredients WHERE recipe_id = '${recipeId}'), total_fiber_g = (SELECT ROUND(SUM(fiber_g)::numeric, 2) FROM recipe_ingredients WHERE recipe_id = '${recipeId}'), calories_per_100g = (SELECT ROUND(SUM(calories) / NULLIF(SUM(weight_grams), 0) * 100) FROM recipe_ingredients WHERE recipe_id = '${recipeId}') WHERE id = '${recipeId}';\n`;
  }

  sql += '\nCOMMIT;\n';
  const outFile = '../supabase/migrations/20260226100000_fix_ingredient_macros.sql';
  fs.writeFileSync(outFile, sql);
  console.log('SQL saved to', outFile);
}

main().catch(e => console.error(e));


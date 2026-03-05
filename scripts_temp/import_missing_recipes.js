const fs = require('fs');
const XLSX = require('./node_modules/xlsx');
const crypto = require('crypto');

const wb = XLSX.readFile('../Ricette per APP_v2.xlsx');
const dbRecipes = JSON.parse(fs.readFileSync('db_recipes.json'));

// Load BDA nutrition directly from the BDA Excel file (complete data!)
const bdaWb = XLSX.readFile('../BDA_Banca Dati Alimentari_V1.2022.xlsx');
const bdaWs = bdaWb.Sheets['BDA-2022'];
const bdaData = XLSX.utils.sheet_to_json(bdaWs, { header: 1 });

const CREATED_BY = '9b1cd123-6145-4763-89ac-6e629a4b4b6c';

function normalize(s) {
  return (s || '').toLowerCase().trim().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}

function uuid() {
  return crypto.randomUUID();
}

function esc(s) {
  return (s || '').replace(/'/g, "''");
}

function round2(n) { return Math.round(n * 100) / 100; }

// BDA nutrition map from Excel: code -> {kcal, protein, fat, carbs, fiber}
// Column indices: 1=code, 7=kcal, 9=protein, 12=fat, 16=carbs, 19=fiber
// Also store by BASE code (without _1 or _2 suffix) for flexible matching
const bdaMap = {};
const bdaMapBase = {}; // key = base code (e.g., "50"), value = nutrition data
for (let i = 3; i < bdaData.length; i++) {
  const row = bdaData[i];
  const code = (row[1] || '').toString();
  if (code) {
    // In BDA, negative values (e.g. -3) mean "not available / trace" -> treat as 0
    const p = (v) => { const x = parseFloat(v); return (isNaN(x) || x < 0) ? 0 : x; };
    const nutrition = {
      kcal:    p(row[7]),
      protein: p(row[9]),
      fat:     p(row[12]),
      carbs:   p(row[16]),
      fiber:   p(row[19]),
    };
    bdaMap[code] = nutrition;
    // Also store by base code (strip _1 or _2 suffix)
    const baseCode = code.replace(/_[12]$/, '');
    if (!bdaMapBase[baseCode]) bdaMapBase[baseCode] = nutrition;
  }
}
console.log('Loaded', Object.keys(bdaMap).length, 'BDA codes from Excel');

// Function to get BDA nutrition, trying exact match first, then base code match
function getBdaNutrition(code) {
  if (bdaMap[code]) return bdaMap[code];
  const baseCode = code.replace(/_[12]$/, '');
  if (bdaMapBase[baseCode]) return bdaMapBase[baseCode];
  return null;
}

// Build set of recipe titles already in DB
const dbTitles = new Set(dbRecipes.map(r => normalize(r.title)));

// Parse all recipes from all Excel sheets
function parseSheet(ws) {
  const data = XLSX.utils.sheet_to_json(ws, { header: 1 });
  const recipes = [];
  let current = null;

  data.forEach(row => {
    const col0 = (row[0] || '').toString().trim();
    const col1 = row[1];
    const col3 = (row[3] || '').toString().trim();
    const col4 = (row[4] || '').toString().trim();
    const col6 = row[6]; // kcal per 100g (per ingredient), OR kcal/100g of recipe on summary row

    // "Analisi per porzione" summary row — col3 is null, col6 = pre-calculated kcal/100g of recipe
    if (col0 === 'Analisi per porzione' && current) {
      current.calPer100g = parseFloat(col6) || null;
      return;
    }

    // Skip other summary / header rows
    if (col0 === 'Analisi per 100 g' || col0 === 'PESI' || col0 === 'Quantita') return;

    // Recipe title row: col0 text, no weight, no BDA code
    if (col0 && !col1 && !col3) {
      current = { title: col0, ingredients: [], calPer100g: null };
      recipes.push(current);
      return;
    }

    // Ingredient row: must have weight + BDA code
    if (!current || !col1 || !col3) return;
    const weight = parseFloat(col1);
    if (isNaN(weight) || weight <= 0) return;

    const bdaCode = col3;
    const bdaName = col4 || col0; // prefer col4 (actual BDA name), fallback to display name
    const excelKcal = parseFloat(col6) || 0; // kcal per 100g of this ingredient

    const bda = getBdaNutrition(bdaCode);
    const kcalPer100 = bda ? bda.kcal : excelKcal;

    current.ingredients.push({
      ingredient_name: bdaName,
      weight_grams:    round2(weight),
      calories:        round2(weight * kcalPer100 / 100),
      protein_g:       round2(weight * (bda ? bda.protein : 0) / 100),
      carbs_g:         round2(weight * (bda ? bda.carbs : 0) / 100),
      fat_g:           round2(weight * (bda ? bda.fat : 0) / 100),
      fiber_g:         round2(weight * (bda ? bda.fiber : 0) / 100),
    });
  });

  return recipes;
}

// Collect missing recipes from all sheets
const toImport = [];
wb.SheetNames.slice(0, 2).forEach(sheetName => {
  const ws = wb.Sheets[sheetName];
  const recipes = parseSheet(ws);
  recipes.forEach(r => {
    if (!dbTitles.has(normalize(r.title)) && r.ingredients.length > 0) {
      toImport.push(r);
    }
  });
});

// Deduplicate by title (in case same recipe appears in both sheets)
const seen = new Set();
const unique = toImport.filter(r => {
  const key = normalize(r.title);
  if (seen.has(key)) return false;
  seen.add(key);
  return true;
});

console.log('Recipes to import:', unique.length);

// Generate SQL
let sql = `-- Migration: Import ${unique.length} missing recipes from Excel (PARTE1 + PARTE2)\n`;
sql += `-- Generated: ${new Date().toISOString()}\n\nBEGIN;\n\n`;

unique.forEach(recipe => {
  const recipeId = uuid();
  const totalWeight  = round2(recipe.ingredients.reduce((s, i) => s + i.weight_grams, 0));
  const totalCal     = round2(recipe.ingredients.reduce((s, i) => s + i.calories, 0));
  const totalProtein = round2(recipe.ingredients.reduce((s, i) => s + i.protein_g, 0));
  const totalCarbs   = round2(recipe.ingredients.reduce((s, i) => s + i.carbs_g, 0));
  const totalFat     = round2(recipe.ingredients.reduce((s, i) => s + i.fat_g, 0));
  const totalFiber   = round2(recipe.ingredients.reduce((s, i) => s + i.fiber_g, 0));
  // Use Excel's pre-calculated kcal/100g value (from "Analisi per porzione" row col6)
  // This is the red-underlined value the client showed — it's per 100g of the whole recipe
  const calPer100    = recipe.calPer100g != null
    ? Math.round(recipe.calPer100g)
    : (totalWeight > 0 ? Math.round(totalCal / totalWeight * 100) : 0);

  sql += `-- Recipe: ${recipe.title}\n`;
  sql += `INSERT INTO recipes (id, title, is_public, is_verified, created_by, difficulty, category, prep_time_minutes, cook_time_minutes, servings, total_weight_g, total_calories, calories_per_100g, total_protein_g, total_carbs_g, total_fat_g, total_fiber_g)\n`;
  sql += `VALUES ('${recipeId}', '${esc(recipe.title)}', true, true, '${CREATED_BY}', 'easy', 'lunch', 15, 0, 2, ${totalWeight}, ${Math.round(totalCal)}, ${calPer100}, ${totalProtein}, ${totalCarbs}, ${totalFat}, ${totalFiber});\n\n`;

  recipe.ingredients.forEach(ing => {
    sql += `INSERT INTO recipe_ingredients (id, recipe_id, ingredient_name, food_item_id, quantity, unit, weight_grams, calories, protein_g, carbs_g, fat_g, fiber_g)\n`;
    sql += `VALUES ('${uuid()}', '${recipeId}', '${esc(ing.ingredient_name)}', NULL, ${ing.weight_grams}, 'g', ${ing.weight_grams}, ${ing.calories}, ${ing.protein_g}, ${ing.carbs_g}, ${ing.fat_g}, ${ing.fiber_g});\n`;
  });
  sql += '\n';
});

sql += `COMMIT;\n`;

const outFile = '../supabase/migrations/20260226000000_import_missing_recipes.sql';
fs.writeFileSync(outFile, sql);
console.log(`SQL saved to ${outFile}`);
console.log(`Total INSERT statements: ${unique.length} recipes + their ingredients`);

// Print sample
console.log('\nFirst 3 recipes to import:');
unique.slice(0, 3).forEach(r => {
  const totalCal = round2(r.ingredients.reduce((s, i) => s + i.calories, 0));
  console.log(` - ${r.title} (${r.ingredients.length} ingredients, ${Math.round(totalCal)} kcal)`);
});


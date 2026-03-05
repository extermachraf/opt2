const fs = require('fs');
const XLSX = require('./node_modules/xlsx');

const wb = XLSX.readFile('../Ricette per APP_v2.xlsx');
const dbRecipes = JSON.parse(fs.readFileSync('db_recipes.json'));
const dbIngredients = JSON.parse(fs.readFileSync('db_ingredients.json'));

// Normalize string for matching (remove accents, lowercase, trim)
function normalize(s) {
  return (s || '').toLowerCase().trim()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[''`]/g, "'");
}

// Build recipe name -> id map (normalized)
const recipeNameToId = {};
dbRecipes.forEach(r => { recipeNameToId[normalize(r.title)] = r.id; });

// Group DB ingredients by recipe_id
const dbIngByRecipe = {};
dbIngredients.forEach(ing => {
  if (!dbIngByRecipe[ing.recipe_id]) dbIngByRecipe[ing.recipe_id] = [];
  dbIngByRecipe[ing.recipe_id].push(ing);
});

const nameUpdates = []; // { id, old_name, new_name }
const updatedIds = new Set(); // track IDs already assigned to prevent duplicates
let totalMatched = 0;
let totalSkipped = 0;
let totalUnmatched = 0;

wb.SheetNames.slice(0, 2).forEach(sheetName => {
  const ws = wb.Sheets[sheetName];
  const data = XLSX.utils.sheet_to_json(ws, { header: 1 });

  let currentRecipe = null;

  data.forEach((row) => {
    // Recipe name row: col0 has value but no col1/col3
    if (row[0] && !row[1] && !row[3] && typeof row[0] === 'string'
        && row[0] !== 'Analisi per porzione' && row[0] !== 'Analisi per 100 g') {
      currentRecipe = row[0].trim();
      return;
    }

    // Ingredient row: must have weight, BDA code, and BDA name
    if (!currentRecipe || !row[1] || !row[3] || !row[4]) return;

    const displayName = (row[0] || '').toString().trim();   // group label (e.g. "Besciamella")
    const bdaName = (row[4] || '').toString().trim();        // actual BDA name (e.g. "LATTE DI VACCA...")
    const weight = parseFloat(row[1]);

    // Only update when display name differs from BDA name
    if (normalize(displayName) === normalize(bdaName)) return;

    const recipeId = recipeNameToId[normalize(currentRecipe)];
    if (!recipeId) return;

    const recipeDbIngs = dbIngByRecipe[recipeId] || [];

    // STRICT match: ingredient_name matches the Excel display label AND weight matches
    // This safely handles group labels like "Besciamella" with multiple rows at different weights
    const matches = recipeDbIngs.filter(dbIng =>
      normalize(dbIng.ingredient_name) === normalize(displayName) &&
      Math.abs(dbIng.weight_grams - weight) < 0.1
    );

    if (matches.length === 0) {
      totalUnmatched++;
      return;
    }

    matches.forEach(dbIng => {
      // Skip if this ID was already matched to a different name (prevents conflicts)
      if (updatedIds.has(dbIng.id)) {
        totalSkipped++;
        return;
      }
      updatedIds.add(dbIng.id);
      nameUpdates.push({ id: dbIng.id, old_name: dbIng.ingredient_name, new_name: bdaName });
      totalMatched++;
    });
  });
});

console.log('Name updates needed:', nameUpdates.length);
console.log('Matched:', totalMatched, '| Unmatched:', totalUnmatched);
console.log('Sample updates:', JSON.stringify(nameUpdates.slice(0, 5), null, 2));

// Generate SQL
let sql = `-- Migration: Fix ingredient display names using BDA food names from Excel
-- Only updates rows where the ingredient_name was a group label (e.g. Besciamella)
-- Generated: ${new Date().toISOString()}

BEGIN;

`;

nameUpdates.forEach(u => {
  const escapedNew = u.new_name.replace(/'/g, "''");
  sql += `UPDATE recipe_ingredients SET ingredient_name = '${escapedNew}' WHERE id = '${u.id}';\n`;
});

sql += `\nCOMMIT;\n`;

fs.writeFileSync('../supabase/migrations/20260223100000_fix_ingredient_names.sql', sql);
console.log('\nSQL migration saved to supabase/migrations/20260223100000_fix_ingredient_names.sql');
console.log('Total UPDATE statements:', nameUpdates.length);


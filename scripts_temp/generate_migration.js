const fs = require('fs');

const excelIngredients = JSON.parse(fs.readFileSync('excel_ingredients.json'));
const bdaNutrition = JSON.parse(fs.readFileSync('bda_nutrition.json'));
const dbRecipes = JSON.parse(fs.readFileSync('db_recipes.json'));
const dbIngredients = JSON.parse(fs.readFileSync('db_ingredients.json'));

// Build BDA nutrition map: code -> {kcal, protein, fat, carbs, fiber}
const bdaMap = {};
bdaNutrition.forEach(row => {
  const code = row['Codice Alimento'];
  bdaMap[code] = {
    kcal: parseFloat(row['Energia, Ric con fibra (kcal)']) || 0,
    protein: parseFloat(row['Proteine totali']) || 0,
    fat: parseFloat(row['Lipidi totali']) || 0,
    carbs: parseFloat(row['Carboidrati disponibili (MSE)']) || 0,
    fiber: parseFloat(row['Fibra alimentare totale']) || 0,
  };
});

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

const updates = [];
const unmatchedRecipes = new Set();
const unmatchedIngredients = [];

excelIngredients.forEach(exIng => {
  const recipeId = recipeNameToId[normalize(exIng.recipe_name)];
  if (!recipeId) {
    unmatchedRecipes.add(exIng.recipe_name);
    return;
  }

  const recipeDbIngs = dbIngByRecipe[recipeId] || [];

  // Match by weight_grams within ±0.1 tolerance
  const matchingIngs = recipeDbIngs.filter(dbIng => 
    Math.abs(dbIng.weight_grams - exIng.weight_grams) < 0.1
  );

  if (matchingIngs.length === 0) {
    unmatchedIngredients.push({ recipe: exIng.recipe_name, name: exIng.display_name, weight: exIng.weight_grams });
    return;
  }

  // If multiple matches (same weight), pick by ingredient name similarity
  let dbIng = matchingIngs[0];
  if (matchingIngs.length > 1) {
    const normDisplay = normalize(exIng.display_name);
    const byName = matchingIngs.find(i => normalize(i.ingredient_name).includes(normDisplay.substring(0, 5)));
    if (byName) dbIng = byName;
  }

  const bda = bdaMap[exIng.bda_code];
  const kcalPer100g = bda ? bda.kcal : exIng.kcal_per_100g;
  
  const correctCalories = Math.round(exIng.weight_grams * kcalPer100g / 100 * 100) / 100;
  const correctProtein = bda ? Math.round(exIng.weight_grams * bda.protein / 100 * 100) / 100 : dbIng.protein_g;
  const correctFat = bda ? Math.round(exIng.weight_grams * bda.fat / 100 * 100) / 100 : dbIng.fat_g;
  const correctCarbs = bda ? Math.round(exIng.weight_grams * bda.carbs / 100 * 100) / 100 : dbIng.carbs_g;
  const correctFiber = bda ? Math.round(exIng.weight_grams * bda.fiber / 100 * 100) / 100 : dbIng.fiber_g;

  const calDiff = Math.abs(correctCalories - (dbIng.calories || 0));
  if (calDiff > 0.5) {
    updates.push({ id: dbIng.id, calories: correctCalories, protein_g: correctProtein, fat_g: correctFat, carbs_g: correctCarbs, fiber_g: correctFiber, bda_code: exIng.bda_code, recipe: exIng.recipe_name, display: exIng.display_name, weight: exIng.weight_grams, oldCal: dbIng.calories, newCal: correctCalories });
  }
});

console.log('Updates needed:', updates.length);
console.log('Unmatched recipes:', unmatchedRecipes.size, [...unmatchedRecipes].slice(0,5));
console.log('Unmatched ingredients:', unmatchedIngredients.length, unmatchedIngredients.slice(0,3));
console.log('Sample updates:', JSON.stringify(updates.slice(0,3), null, 2));
fs.writeFileSync('updates.json', JSON.stringify(updates, null, 2));


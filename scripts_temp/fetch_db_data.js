const url = 'https://jnukglbwreegcluvwgad.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpudWtnbGJ3cmVlZ2NsdXZ3Z2FkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5MTgyMTksImV4cCI6MjA4NjI3ODIxOX0.5LS97w7_UiiNj86D3yau9VFiy0vNWiKsG0wwb5OWb-I';
const fs = require('fs');

async function fetchAll(endpoint) {
  let allData = [];
  let offset = 0;
  const limit = 500;
  while (true) {
    const resp = await fetch(url + endpoint + '&limit=' + limit + '&offset=' + offset, {
      headers: { 'apikey': key, 'Authorization': 'Bearer ' + key, 'Range-Unit': 'items' }
    });
    const data = await resp.json();
    if (!Array.isArray(data) || data.length === 0) break;
    allData = allData.concat(data);
    if (data.length < limit) break;
    offset += limit;
  }
  return allData;
}

async function main() {
  console.log('Fetching recipes...');
  const recipes = await fetchAll('/rest/v1/recipes?select=id,title&is_public=eq.true');
  console.log('Fetched', recipes.length, 'recipes');
  fs.writeFileSync('db_recipes.json', JSON.stringify(recipes, null, 2));

  console.log('Fetching recipe_ingredients...');
  const ingredients = await fetchAll('/rest/v1/recipe_ingredients?select=id,recipe_id,ingredient_name,weight_grams,calories,protein_g,carbs_g,fat_g,fiber_g');
  console.log('Fetched', ingredients.length, 'recipe_ingredients');
  fs.writeFileSync('db_ingredients.json', JSON.stringify(ingredients, null, 2));

  console.log('Done. Sample recipe_ingredient:', JSON.stringify(ingredients[0], null, 2));
}

main().catch(e => console.error(e));


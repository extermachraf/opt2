const url = 'https://jnukglbwreegcluvwgad.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpudWtnbGJ3cmVlZ2NsdXZ3Z2FkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5MTgyMTksImV4cCI6MjA4NjI3ODIxOX0.5LS97w7_UiiNj86D3yau9VFiy0vNWiKsG0wwb5OWb-I';
const fs = require('fs');

const bdaCodes = JSON.parse(fs.readFileSync('bda_codes.json'));
console.log('Fetching nutrition for', bdaCodes.length, 'BDA codes...');

const selectCols = [
  '"Codice Alimento"',
  '"Energia, Ric con fibra (kcal)"',
  '"Proteine totali"',
  '"Lipidi totali"',
  '"Carboidrati disponibili (MSE)"',
  '"Fibra alimentare totale"'
].join(',');

const codesFilter = bdaCodes.map(c => '"' + c + '"').join(',');

const apiUrl = url + '/rest/v1/Food%20Ingredients'
  + '?select=' + encodeURIComponent(selectCols)
  + '&"Codice Alimento"=in.(' + codesFilter + ')'
  + '&limit=300';

fetch(apiUrl, {
  headers: { 'apikey': key, 'Authorization': 'Bearer ' + key }
}).then(r => r.json()).then(data => {
  if (Array.isArray(data)) {
    console.log('Fetched', data.length, 'BDA entries');
    fs.writeFileSync('bda_nutrition.json', JSON.stringify(data, null, 2));
    console.log('Saved to bda_nutrition.json');
    if (data.length > 0) console.log('Sample:', JSON.stringify(data[0], null, 2));
  } else {
    console.log('Error:', JSON.stringify(data));
  }
}).catch(e => console.error(e));


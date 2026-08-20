/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text3208210256",
        "max": 0,
        "min": 0,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_OIhD",
        "max": 0,
        "min": 0,
        "name": "name",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_67Jm",
        "max": 0,
        "min": 0,
        "name": "vorname",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "json1763761355",
        "maxSize": 1,
        "name": "wreath",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_1995500390",
    "indexes": [],
    "listRule": "",
    "name": "mostWreaths2026",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "Select wrestler.id, wrestler.name, wrestler.vorname, SUM(rankings.wreath) as wreath\nFROM wrestler\nLEFT JOIN rankings on rankings.wrestler = wrestler.id\nLEFT JOIN places on rankings.place = places.id\nWHERE places.year LIKE \"%2026%\"\nGROUP BY wrestler.id\nORDER BY wreath DESC\nLIMIT 5",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1995500390");

  return app.delete(collection);
})

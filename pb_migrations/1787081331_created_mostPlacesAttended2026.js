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
        "id": "_clone_r1K4",
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
        "id": "_clone_soyx",
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
        "id": "number3518960019",
        "max": null,
        "min": null,
        "name": "placesAttended",
        "onlyInt": true,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      }
    ],
    "id": "pbc_3133774822",
    "indexes": [],
    "listRule": "",
    "name": "mostPlacesAttended2026",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "Select wrestler.id, wrestler.name, wrestler.vorname, COUNT(rankings.place) as placesAttended\nFROM wrestler\nLEFT JOIN rankings on rankings.wrestler = wrestler.id\nLEFT JOIN places on rankings.place = places.id\nWHERE places.year LIKE \"%2026%\"\nGROUP BY wrestler.id\nORDER BY placesAttended DESC\nLIMIT 5",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3133774822");

  return app.delete(collection);
})

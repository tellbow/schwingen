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
        "hidden": false,
        "id": "json490044201",
        "maxSize": 1,
        "name": "averagePoints",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "cascadeDelete": false,
        "collectionId": "flbu2yiiq2n6ku3",
        "hidden": false,
        "id": "relation1344262760",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "wid",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_ejBV",
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
        "id": "_clone_73G1",
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
        "id": "_clone_SpRq",
        "max": "",
        "min": "",
        "name": "year",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "date"
      }
    ],
    "id": "pbc_3314408786",
    "indexes": [],
    "listRule": "",
    "name": "averagePoints2026",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT rankings.id, AVG(rankings.points) as averagePoints, wrestler.id as wid, wrestler.name, wrestler.vorname, places.year\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nLEFT JOIN places on places.id = rankings.place\nLEFT JOIN placeType on placeType.id = places.placeType\nWHERE rankings.status != \"Unfall\" AND placeType.type NOT LIKE \"%idgenössisch%\" AND places.year LIKE \"%2026%\"\nGROUP BY wrestler.id\nHAVING COUNT(rankings.points) >= 5\nORDER BY averagePoints DESC\nLIMIT 5",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3314408786");

  return app.delete(collection);
})

migrate((db) => {
  const collection = new Collection({
    "id": "ov1vocnfjg6hfx7",
    "created": "2023-04-30 08:30:55.822Z",
    "updated": "2023-04-30 08:30:55.822Z",
    "name": "averagePoints",
    "type": "view",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "pzoowwac",
        "name": "averagePoints",
        "type": "json",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "o4ewrlqa",
        "name": "name",
        "type": "text",
        "required": true,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "h8phzhan",
        "name": "vorname",
        "type": "text",
        "required": true,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {
      "query": "SELECT rankings.id, AVG(rankings.points) as averagePoints, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id\nORDER BY averagePoints\nLIMIT 5"
    }
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("ov1vocnfjg6hfx7");

  return dao.deleteCollection(collection);
})

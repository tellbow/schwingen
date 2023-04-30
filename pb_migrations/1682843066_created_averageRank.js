migrate((db) => {
  const collection = new Collection({
    "id": "vv2lrtpsacbq9el",
    "created": "2023-04-30 08:24:26.180Z",
    "updated": "2023-04-30 08:24:26.180Z",
    "name": "averageRank",
    "type": "view",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "h81ltij6",
        "name": "rank",
        "type": "text",
        "required": false,
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
      "query": "SELECT rankings.id, rankings.rank\nFROM rankings"
    }
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("vv2lrtpsacbq9el");

  return dao.deleteCollection(collection);
})

migrate((db) => {
  const collection = new Collection({
    "id": "vkd6rjg0atz77bn",
    "created": "2023-04-26 17:59:28.005Z",
    "updated": "2023-04-26 17:59:28.005Z",
    "name": "bouts",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "e7tjht5p",
        "name": "result",
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
        "id": "8xpdupuh",
        "name": "points",
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
        "id": "zpomjpdj",
        "name": "fight_round",
        "type": "number",
        "required": true,
        "unique": false,
        "options": {
          "min": 1,
          "max": 10
        }
      },
      {
        "system": false,
        "id": "085n9dzm",
        "name": "wrestler",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "flbu2yiiq2n6ku3",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": []
        }
      },
      {
        "system": false,
        "id": "ebuvnbay",
        "name": "opponent",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "flbu2yiiq2n6ku3",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": []
        }
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("vkd6rjg0atz77bn");

  return dao.deleteCollection(collection);
})

migrate((db) => {
  const collection = new Collection({
    "id": "5dcdp7svys3woho",
    "created": "2023-04-19 20:49:51.541Z",
    "updated": "2023-04-19 20:49:51.541Z",
    "name": "rankings",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "jddwxolj",
        "name": "rank",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "g5slusoy",
        "name": "points",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "sy2jvmtp",
        "name": "result",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "ksqfxiok",
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
        "id": "56tr5kar",
        "name": "place",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "4fg2k4xlss29p5d",
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
  const collection = dao.findCollectionByNameOrId("5dcdp7svys3woho");

  return dao.deleteCollection(collection);
})

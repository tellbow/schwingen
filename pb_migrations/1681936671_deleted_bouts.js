migrate((db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("e3x9otp3xtsdu21");

  return dao.deleteCollection(collection);
}, (db) => {
  const collection = new Collection({
    "id": "e3x9otp3xtsdu21",
    "created": "2023-02-11 15:19:28.123Z",
    "updated": "2023-04-19 20:37:37.470Z",
    "name": "bouts",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "nwlto0z6",
        "name": "result",
        "type": "text",
        "required": true,
        "unique": false,
        "options": {
          "min": null,
          "max": 1,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "mkpgx6vx",
        "name": "wrestler1",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "flbu2yiiq2n6ku3",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": null
        }
      },
      {
        "system": false,
        "id": "xvsjfymu",
        "name": "level",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": 3,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "1jnebbqs",
        "name": "points",
        "type": "number",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": 10
        }
      },
      {
        "system": false,
        "id": "tavokirl",
        "name": "fight_round",
        "type": "number",
        "required": true,
        "unique": false,
        "options": {
          "min": null,
          "max": null
        }
      },
      {
        "system": false,
        "id": "r0ptiiwp",
        "name": "wrestler2",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "flbu2yiiq2n6ku3",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": null
        }
      },
      {
        "system": false,
        "id": "qzg5mwxe",
        "name": "place",
        "type": "relation",
        "required": true,
        "unique": false,
        "options": {
          "collectionId": "okdivlqrnm0qtd6",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": null
        }
      }
    ],
    "indexes": [
      "CREATE INDEX `_e3x9otp3xtsdu21_created_idx` ON `bouts` (`created`)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
})

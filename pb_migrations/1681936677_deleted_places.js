migrate((db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("okdivlqrnm0qtd6");

  return dao.deleteCollection(collection);
}, (db) => {
  const collection = new Collection({
    "id": "okdivlqrnm0qtd6",
    "created": "2023-02-11 15:17:22.716Z",
    "updated": "2023-04-19 20:37:37.470Z",
    "name": "places",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "9zcocutb",
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
        "id": "i5zrtka8",
        "name": "ort",
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
        "id": "7fwsdquw",
        "name": "year",
        "type": "date",
        "required": true,
        "unique": false,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "system": false,
        "id": "idypovhi",
        "name": "statistik",
        "type": "url",
        "required": false,
        "unique": false,
        "options": {
          "exceptDomains": [],
          "onlyDomains": [
            "esv.ch"
          ]
        }
      }
    ],
    "indexes": [
      "CREATE INDEX `_okdivlqrnm0qtd6_created_idx` ON `places` (`created`)"
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

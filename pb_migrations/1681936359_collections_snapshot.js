migrate((db) => {
  const snapshot = [
    {
      "id": "_pb_users_auth_",
      "created": "2023-02-11 15:02:29.928Z",
      "updated": "2023-04-19 20:31:57.982Z",
      "name": "users",
      "type": "auth",
      "system": false,
      "schema": [
        {
          "system": false,
          "id": "users_name",
          "name": "name",
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
          "id": "users_avatar",
          "name": "avatar",
          "type": "file",
          "required": false,
          "unique": false,
          "options": {
            "maxSelect": 1,
            "maxSize": 5242880,
            "mimeTypes": [
              "image/jpeg",
              "image/png",
              "image/svg+xml",
              "image/gif",
              "image/webp"
            ],
            "thumbs": null
          }
        }
      ],
      "indexes": [
        "CREATE INDEX `__pb_users_auth__created_idx` ON `users` (`created`)"
      ],
      "listRule": "id = @request.auth.id",
      "viewRule": "id = @request.auth.id",
      "createRule": "",
      "updateRule": "id = @request.auth.id",
      "deleteRule": "id = @request.auth.id",
      "options": {
        "allowEmailAuth": true,
        "allowOAuth2Auth": true,
        "allowUsernameAuth": true,
        "exceptEmailDomains": null,
        "manageRule": null,
        "minPasswordLength": 8,
        "onlyEmailDomains": null,
        "requireEmail": false
      }
    },
    {
      "id": "flbu2yiiq2n6ku3",
      "created": "2023-02-11 15:13:33.295Z",
      "updated": "2023-04-19 20:31:57.983Z",
      "name": "wrestler",
      "type": "base",
      "system": false,
      "schema": [
        {
          "system": false,
          "id": "g1iwogeb",
          "name": "nummer",
          "type": "number",
          "required": false,
          "unique": false,
          "options": {
            "min": null,
            "max": null
          }
        },
        {
          "system": false,
          "id": "leqhsk8s",
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
          "id": "ro8kfdhb",
          "name": "vorname",
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
          "id": "2khz4bgk",
          "name": "year",
          "type": "date",
          "required": false,
          "unique": false,
          "options": {
            "min": "",
            "max": ""
          }
        },
        {
          "system": false,
          "id": "o0qdybzi",
          "name": "category",
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
          "id": "wczrlwrh",
          "name": "club",
          "type": "relation",
          "required": false,
          "unique": false,
          "options": {
            "collectionId": "ekzbhw4zkqbuioc",
            "cascadeDelete": false,
            "minSelect": null,
            "maxSelect": 1,
            "displayFields": null
          }
        }
      ],
      "indexes": [
        "CREATE INDEX `_flbu2yiiq2n6ku3_created_idx` ON `wrestler` (`created`)"
      ],
      "listRule": "@request.auth.id != \"\"",
      "viewRule": "@request.auth.id != \"\"",
      "createRule": null,
      "updateRule": null,
      "deleteRule": null,
      "options": {}
    },
    {
      "id": "okdivlqrnm0qtd6",
      "created": "2023-02-11 15:17:22.716Z",
      "updated": "2023-04-19 20:16:39.293Z",
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
    },
    {
      "id": "e3x9otp3xtsdu21",
      "created": "2023-02-11 15:19:28.123Z",
      "updated": "2023-04-19 20:16:39.293Z",
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
    },
    {
      "id": "ipfnl9797wefu1k",
      "created": "2023-02-11 15:40:48.997Z",
      "updated": "2023-04-19 20:31:57.983Z",
      "name": "canton",
      "type": "base",
      "system": false,
      "schema": [
        {
          "system": false,
          "id": "u6sdqcex",
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
          "id": "dgtrdzyk",
          "name": "association",
          "type": "relation",
          "required": false,
          "unique": false,
          "options": {
            "collectionId": "jpa2o3qgh7rbt1k",
            "cascadeDelete": false,
            "minSelect": null,
            "maxSelect": 1,
            "displayFields": null
          }
        }
      ],
      "indexes": [
        "CREATE INDEX `_ipfnl9797wefu1k_created_idx` ON \"canton\" (`created`)"
      ],
      "listRule": "@request.auth.id != \"\"",
      "viewRule": "@request.auth.id != \"\"",
      "createRule": null,
      "updateRule": null,
      "deleteRule": null,
      "options": {}
    },
    {
      "id": "jpa2o3qgh7rbt1k",
      "created": "2023-02-11 15:41:20.967Z",
      "updated": "2023-04-19 20:31:57.983Z",
      "name": "association",
      "type": "base",
      "system": false,
      "schema": [
        {
          "system": false,
          "id": "hj9qoe79",
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
          "id": "hi1jsncn",
          "name": "abbreviation",
          "type": "text",
          "required": false,
          "unique": false,
          "options": {
            "min": null,
            "max": 4,
            "pattern": ""
          }
        }
      ],
      "indexes": [
        "CREATE INDEX `_jpa2o3qgh7rbt1k_created_idx` ON `association` (`created`)"
      ],
      "listRule": "@request.auth.id != \"\"",
      "viewRule": "@request.auth.id != \"\"",
      "createRule": null,
      "updateRule": null,
      "deleteRule": null,
      "options": {}
    },
    {
      "id": "ekzbhw4zkqbuioc",
      "created": "2023-02-11 16:10:19.242Z",
      "updated": "2023-04-19 20:31:57.983Z",
      "name": "club",
      "type": "base",
      "system": false,
      "schema": [
        {
          "system": false,
          "id": "6xpnlmxq",
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
          "id": "j2mgcgqi",
          "name": "canton",
          "type": "relation",
          "required": false,
          "unique": false,
          "options": {
            "collectionId": "ipfnl9797wefu1k",
            "cascadeDelete": false,
            "minSelect": null,
            "maxSelect": 1,
            "displayFields": null
          }
        }
      ],
      "indexes": [
        "CREATE INDEX `_ekzbhw4zkqbuioc_created_idx` ON `club` (`created`)"
      ],
      "listRule": "@request.auth.id != \"\"",
      "viewRule": "@request.auth.id != \"\"",
      "createRule": null,
      "updateRule": null,
      "deleteRule": null,
      "options": {}
    }
  ];

  const collections = snapshot.map((item) => new Collection(item));

  return Dao(db).importCollections(collections, true, null);
}, (db) => {
  return null;
})

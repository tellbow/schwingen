migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("vkd6rjg0atz77bn")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "m7lejfwp",
    "name": "place",
    "type": "relation",
    "required": true,
    "unique": false,
    "options": {
      "collectionId": "4fg2k4xlss29p5d",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": 1,
      "displayFields": []
    }
  }))

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "085n9dzm",
    "name": "wrestler",
    "type": "relation",
    "required": true,
    "unique": false,
    "options": {
      "collectionId": "flbu2yiiq2n6ku3",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": 1,
      "displayFields": []
    }
  }))

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "ebuvnbay",
    "name": "opponent",
    "type": "relation",
    "required": true,
    "unique": false,
    "options": {
      "collectionId": "flbu2yiiq2n6ku3",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": 1,
      "displayFields": []
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("vkd6rjg0atz77bn")

  // remove
  collection.schema.removeField("m7lejfwp")

  // update
  collection.schema.addField(new SchemaField({
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
  }))

  // update
  collection.schema.addField(new SchemaField({
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
  }))

  return dao.saveCollection(collection)
})

migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("vv2lrtpsacbq9el")

  collection.options = {
    "query": "SELECT rankings.id, rankings.rank\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id"
  }

  // remove
  collection.schema.removeField("h81ltij6")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "hpvpqqry",
    "name": "rank",
    "type": "text",
    "required": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("vv2lrtpsacbq9el")

  collection.options = {
    "query": "SELECT rankings.id, rankings.rank\nFROM rankings"
  }

  // add
  collection.schema.addField(new SchemaField({
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
  }))

  // remove
  collection.schema.removeField("hpvpqqry")

  return dao.saveCollection(collection)
})

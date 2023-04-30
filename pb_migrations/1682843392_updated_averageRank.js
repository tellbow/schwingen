migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("vv2lrtpsacbq9el")

  collection.options = {
    "query": "SELECT rankings.id, AVG(rankings.rank) as averageRank, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id\nORDER BY averageRank\nLIMIT 50"
  }

  // remove
  collection.schema.removeField("vj21fwul")

  // remove
  collection.schema.removeField("6hlf1ut7")

  // remove
  collection.schema.removeField("5frkrnf5")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "na7eekl1",
    "name": "averageRank",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "gmwgrmxr",
    "name": "name",
    "type": "text",
    "required": true,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "dgyq6snl",
    "name": "vorname",
    "type": "text",
    "required": true,
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
    "query": "SELECT rankings.id, AVG(rankings.rank) as averageRank, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id\nORDER BY averageRank\nLIMIT 5"
  }

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "vj21fwul",
    "name": "averageRank",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "6hlf1ut7",
    "name": "name",
    "type": "text",
    "required": true,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "5frkrnf5",
    "name": "vorname",
    "type": "text",
    "required": true,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  // remove
  collection.schema.removeField("na7eekl1")

  // remove
  collection.schema.removeField("gmwgrmxr")

  // remove
  collection.schema.removeField("dgyq6snl")

  return dao.saveCollection(collection)
})

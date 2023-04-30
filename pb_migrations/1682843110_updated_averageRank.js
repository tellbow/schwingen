migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("vv2lrtpsacbq9el")

  collection.options = {
    "query": "SELECT rankings.id, rankings.rank, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id"
  }

  // remove
  collection.schema.removeField("awbcogdz")

  // remove
  collection.schema.removeField("bbjnrxzw")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "wjwdh8ny",
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

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "g7wrfmil",
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
    "id": "kmxesivk",
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
    "query": "SELECT rankings.id, rankings.rank, wrestler.name\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id"
  }

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "awbcogdz",
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

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "bbjnrxzw",
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

  // remove
  collection.schema.removeField("wjwdh8ny")

  // remove
  collection.schema.removeField("g7wrfmil")

  // remove
  collection.schema.removeField("kmxesivk")

  return dao.saveCollection(collection)
})

migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("ov1vocnfjg6hfx7")

  collection.options = {
    "query": "SELECT rankings.id, AVG(rankings.points) as averagePoints, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id\nORDER BY averagePoints DESC\nLIMIT 5"
  }

  // remove
  collection.schema.removeField("d9cm3vei")

  // remove
  collection.schema.removeField("cy9dwflq")

  // remove
  collection.schema.removeField("2rlxe1il")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "mboiw5ik",
    "name": "averagePoints",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "mwjv2afg",
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
    "id": "iiqsrguu",
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
  const collection = dao.findCollectionByNameOrId("ov1vocnfjg6hfx7")

  collection.options = {
    "query": "SELECT rankings.id, AVG(rankings.points) as averagePoints, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id\nORDER BY averagePoints ASC\nLIMIT 5"
  }

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "d9cm3vei",
    "name": "averagePoints",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "cy9dwflq",
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
    "id": "2rlxe1il",
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
  collection.schema.removeField("mboiw5ik")

  // remove
  collection.schema.removeField("mwjv2afg")

  // remove
  collection.schema.removeField("iiqsrguu")

  return dao.saveCollection(collection)
})

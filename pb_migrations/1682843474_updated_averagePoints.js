migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("ov1vocnfjg6hfx7")

  collection.options = {
    "query": "SELECT rankings.id, AVG(rankings.points) as averagePoints, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id\nORDER BY averagePoints ASC\nLIMIT 5"
  }

  // remove
  collection.schema.removeField("pzoowwac")

  // remove
  collection.schema.removeField("o4ewrlqa")

  // remove
  collection.schema.removeField("h8phzhan")

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

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("ov1vocnfjg6hfx7")

  collection.options = {
    "query": "SELECT rankings.id, AVG(rankings.points) as averagePoints, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id\nORDER BY averagePoints\nLIMIT 5"
  }

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "pzoowwac",
    "name": "averagePoints",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "o4ewrlqa",
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
    "id": "h8phzhan",
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
  collection.schema.removeField("d9cm3vei")

  // remove
  collection.schema.removeField("cy9dwflq")

  // remove
  collection.schema.removeField("2rlxe1il")

  return dao.saveCollection(collection)
})

migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("vv2lrtpsacbq9el")

  collection.options = {
    "query": "SELECT rankings.id, AVG(rankings.rank) as averageRank, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id\nORDER BY averageRank"
  }

  // remove
  collection.schema.removeField("hxypjz7g")

  // remove
  collection.schema.removeField("xxeutmqd")

  // remove
  collection.schema.removeField("1np43g17")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "crlo6sna",
    "name": "averageRank",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "wtbwxupp",
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
    "id": "ch7zgxof",
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
    "query": "SELECT rankings.id, AVG(rankings.rank) as averageRank, wrestler.name, wrestler.vorname\nFROM rankings\nLEFT JOIN wrestler on wrestler.id = rankings.wrestler\nGROUP BY wrestler.id"
  }

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "hxypjz7g",
    "name": "averageRank",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "xxeutmqd",
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
    "id": "1np43g17",
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
  collection.schema.removeField("crlo6sna")

  // remove
  collection.schema.removeField("wtbwxupp")

  // remove
  collection.schema.removeField("ch7zgxof")

  return dao.saveCollection(collection)
})

/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("txqims2xp5hxfa2")

  // update collection data
  unmarshal({
    "viewQuery": "Select wrestler.id, wrestler.name, wrestler.vorname, COUNT(rankings.place) as wins, SUM(rankings.wreath) as wreath\nFROM wrestler\nLEFT JOIN rankings on rankings.wrestler = wrestler.id\nWHERE rankings.rank = \"1\"\nGROUP BY wrestler.id\nORDER BY wins DESC\nLIMIT 5"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_e1f2")

  // remove field
  collection.fields.removeById("_clone_72zJ")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_lCWB",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_qDOz",
    "max": 0,
    "min": 0,
    "name": "vorname",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("txqims2xp5hxfa2")

  // update collection data
  unmarshal({
    "viewQuery": "Select wrestler.id, wrestler.name, wrestler.vorname, COUNT(rankings.place) as wins, SUM(rankings.wreath) as wreath\nFROM wrestler\nLEFT JOIN rankings on rankings.wrestler = wrestler.id\nWHERE rankings.rank = \"1\" OR rankings.rank = \"1a\" OR rankings.rank = \"1b\" OR rankings.rank = \"1c\" OR rankings.rank = \"1d\"\nGROUP BY wrestler.id\nORDER BY wins DESC\nLIMIT 5"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_e1f2",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_72zJ",
    "max": 0,
    "min": 0,
    "name": "vorname",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // remove field
  collection.fields.removeById("_clone_lCWB")

  // remove field
  collection.fields.removeById("_clone_qDOz")

  return app.save(collection)
})

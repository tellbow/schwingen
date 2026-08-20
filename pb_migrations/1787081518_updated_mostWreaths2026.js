/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1995500390")

  // update collection data
  unmarshal({
    "viewQuery": "Select wrestler.id, wrestler.name, wrestler.vorname, SUM(rankings.wreath) as wreath\nFROM wrestler\nLEFT JOIN rankings on rankings.wrestler = wrestler.id\nLEFT JOIN places on rankings.place = places.id\nWHERE places.year LIKE \"%2026%\"\nGROUP BY wrestler.id\nORDER BY wreath DESC\nLIMIT 5"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_Xa4K")

  // remove field
  collection.fields.removeById("_clone_BctG")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_Vq6y",
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
    "id": "_clone_IXTn",
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
  const collection = app.findCollectionByNameOrId("pbc_1995500390")

  // update collection data
  unmarshal({
    "viewQuery": "Select wrestler.id, wrestler.name, wrestler.vorname, SUM(rankings.wreath) as wreath\nFROM wrestler\nLEFT JOIN rankings on rankings.wrestler = wrestler.id\nLEFT JOIN places on rankings.place = places.id\nWHERE places.year LIKE \"%2026%\"\nGROUP BY wrestler.id\nORDER BY wreath DESC\nLIMIT 10"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_Xa4K",
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
    "id": "_clone_BctG",
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
  collection.fields.removeById("_clone_Vq6y")

  // remove field
  collection.fields.removeById("_clone_IXTn")

  return app.save(collection)
})

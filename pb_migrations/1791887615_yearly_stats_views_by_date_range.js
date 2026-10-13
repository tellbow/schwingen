/// <reference path="../pb_data/types.d.ts" />
const YEARLY_VIEW = /^(averageRank|averagePoints|mostPlacesAttended|mostWins|mostWreaths)(\d{4})$/

const byDateRange = {
  averageRank: (from, to) => `SELECT rankings.id, AVG(rankings.rank) AS averageRank, wrestler.id AS wid, wrestler.name, wrestler.vorname, places.year
FROM places
JOIN rankings ON rankings.place = places.id
LEFT JOIN wrestler ON wrestler.id = rankings.wrestler
WHERE places.year >= '${from}' AND places.year < '${to}' AND rankings.status != 'Unfall'
GROUP BY wrestler.id
HAVING COUNT(rankings.rank) >= 5
ORDER BY averageRank, wrestler.name, wrestler.vorname
LIMIT 5`,
  averagePoints: (from, to) => `SELECT rankings.id, AVG(rankings.points) AS averagePoints, wrestler.id AS wid, wrestler.name, wrestler.vorname, places.year
FROM places
JOIN rankings ON rankings.place = places.id
LEFT JOIN wrestler ON wrestler.id = rankings.wrestler
LEFT JOIN placeType ON placeType.id = places.placeType
WHERE places.year >= '${from}' AND places.year < '${to}' AND rankings.status != 'Unfall' AND placeType.type NOT LIKE '%idgenössisch%'
GROUP BY wrestler.id
HAVING COUNT(rankings.points) >= 5
ORDER BY averagePoints DESC, wrestler.name, wrestler.vorname
LIMIT 5`,
  mostPlacesAttended: (from, to) => `SELECT wrestler.id, wrestler.name, wrestler.vorname, COUNT(rankings.place) AS placesAttended
FROM places
JOIN rankings ON rankings.place = places.id
JOIN wrestler ON wrestler.id = rankings.wrestler
WHERE places.year >= '${from}' AND places.year < '${to}'
GROUP BY wrestler.id
ORDER BY placesAttended DESC, wrestler.name, wrestler.vorname
LIMIT 5`,
  mostWins: (from, to) => `SELECT wrestler.id, wrestler.name, wrestler.vorname, COUNT(rankings.place) AS wins, SUM(rankings.wreath) AS wreath
FROM places
JOIN rankings ON rankings.place = places.id
JOIN wrestler ON wrestler.id = rankings.wrestler
WHERE places.year >= '${from}' AND places.year < '${to}' AND rankings.rank IN ('1', '1a', '1b', '1c', '1d')
GROUP BY wrestler.id
ORDER BY wins DESC, wreath DESC, wrestler.name, wrestler.vorname
LIMIT 5`,
  mostWreaths: (from, to) => `SELECT wrestler.id, wrestler.name, wrestler.vorname, SUM(rankings.wreath) AS wreath
FROM places
JOIN rankings ON rankings.place = places.id
JOIN wrestler ON wrestler.id = rankings.wrestler
WHERE places.year >= '${from}' AND places.year < '${to}'
GROUP BY wrestler.id
ORDER BY wreath DESC, wrestler.name, wrestler.vorname
LIMIT 5`
}

const byYearLike = {
  averageRank: (year) => `SELECT rankings.id, AVG(rankings.rank) as averageRank, wrestler.id as wid, wrestler.name, wrestler.vorname, places.year
FROM rankings
LEFT JOIN wrestler on wrestler.id = rankings.wrestler
LEFT JOIN places on places.id = rankings.place
WHERE rankings.status != "Unfall" AND places.year LIKE "%${year}%"
GROUP BY wrestler.id
HAVING COUNT(rankings.rank) >= 5
ORDER BY averageRank
LIMIT 5`,
  averagePoints: (year) => `SELECT rankings.id, AVG(rankings.points) as averagePoints, wrestler.id as wid, wrestler.name, wrestler.vorname, places.year
FROM rankings
LEFT JOIN wrestler on wrestler.id = rankings.wrestler
LEFT JOIN places on places.id = rankings.place
LEFT JOIN placeType on placeType.id = places.placeType
WHERE rankings.status != "Unfall" AND placeType.type NOT LIKE "%idgenössisch%" AND places.year LIKE "%${year}%"
GROUP BY wrestler.id
HAVING COUNT(rankings.points) >= 5
ORDER BY averagePoints DESC
LIMIT 5`,
  mostPlacesAttended: (year) => `Select wrestler.id, wrestler.name, wrestler.vorname, COUNT(rankings.place) as placesAttended
FROM wrestler
LEFT JOIN rankings on rankings.wrestler = wrestler.id
LEFT JOIN places on rankings.place = places.id
WHERE places.year LIKE "%${year}%"
GROUP BY wrestler.id
ORDER BY placesAttended DESC
LIMIT 5`,
  mostWins: (year) => `Select wrestler.id, wrestler.name, wrestler.vorname, COUNT(rankings.place) as wins, SUM(rankings.wreath) as wreath
FROM wrestler
LEFT JOIN rankings on rankings.wrestler = wrestler.id
LEFT JOIN places on rankings.place = places.id
WHERE (rankings.rank = "1" OR rankings.rank = "1a" OR rankings.rank = "1b" OR rankings.rank = "1c" OR rankings.rank = "1d") AND places.year LIKE "%${year}%"
GROUP BY wrestler.id
ORDER BY wins DESC
LIMIT 5`,
  mostWreaths: (year) => `Select wrestler.id, wrestler.name, wrestler.vorname, SUM(rankings.wreath) as wreath
FROM wrestler
LEFT JOIN rankings on rankings.wrestler = wrestler.id
LEFT JOIN places on rankings.place = places.id
WHERE places.year LIKE "%${year}%"
GROUP BY wrestler.id
ORDER BY wreath DESC
LIMIT 5`
}

function rewriteYearlyViews(app, queryFor) {
  for (const collection of app.findAllCollections("view")) {
    const match = YEARLY_VIEW.exec(collection.name)
    if (!match) continue
    collection.viewQuery = queryFor(match[1], parseInt(match[2]))
    app.save(collection)
  }
}

migrate((app) => {
  const places = app.findCollectionByNameOrId("places")
  places.addIndex("idx_places_year", false, "year")
  app.save(places)

  rewriteYearlyViews(app, (kind, year) => byDateRange[kind](`${year}-01-01`, `${year + 1}-01-01`))
}, (app) => {
  rewriteYearlyViews(app, (kind, year) => byYearLike[kind](year))

  const places = app.findCollectionByNameOrId("places")
  places.removeIndex("idx_places_year")
  app.save(places)
})

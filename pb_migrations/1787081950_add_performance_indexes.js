/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const rankings = app.findCollectionByNameOrId("rankings")
  rankings.addIndex("idx_rankings_wrestler", false, "wrestler")
  rankings.addIndex("idx_rankings_place", false, "place")
  app.save(rankings)

  const bouts = app.findCollectionByNameOrId("bouts")
  bouts.addIndex("idx_bouts_wrestler", false, "wrestler")
  bouts.addIndex("idx_bouts_opponent", false, "opponent")
  bouts.addIndex("idx_bouts_place", false, "place")
  app.save(bouts)

  const wrestler = app.findCollectionByNameOrId("wrestler")
  wrestler.addIndex("idx_wrestler_club", false, "club")
  app.save(wrestler)
}, (app) => {
  const rankings = app.findCollectionByNameOrId("rankings")
  rankings.removeIndex("idx_rankings_wrestler")
  rankings.removeIndex("idx_rankings_place")
  app.save(rankings)

  const bouts = app.findCollectionByNameOrId("bouts")
  bouts.removeIndex("idx_bouts_wrestler")
  bouts.removeIndex("idx_bouts_opponent")
  bouts.removeIndex("idx_bouts_place")
  app.save(bouts)

  const wrestler = app.findCollectionByNameOrId("wrestler")
  wrestler.removeIndex("idx_wrestler_club")
  app.save(wrestler)
})

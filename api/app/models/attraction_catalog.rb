# Static catalog of theme-park attractions (Phase 3C). Each attraction earns
# passive currency over time, collected compute-on-read by
# Simulation::AttractionIncome (income = income_per_day * level * game-days).
# All attractions are gated behind the `attractions` research.
module AttractionCatalog
  Attraction = Data.define(:kind, :name, :income_per_day, :build_cost, :required_tech)

  CATALOG = [
    Attraction.new("carousel",  "Dino Carousel", 60,  5_000,  "attractions"),
    Attraction.new("museum",    "Fossil Museum", 120, 9_000,  "attractions"),
    Attraction.new("gift_shop", "Gift Shop",     200, 14_000, "attractions")
  ].freeze

  INDEX = CATALOG.index_by(&:kind).freeze

  module_function

  def all = CATALOG

  def find(kind) = INDEX[kind.to_s]

  def kinds = INDEX.keys
end

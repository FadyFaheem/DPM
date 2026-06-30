# Static catalog of food-production buildings (Phase 2). Each kind feeds one
# food store, costs currency to build, and is gated behind a research tech.
# Output scales linearly with a building's level.
module FoodProductionCatalog
  Building = Data.define(:kind, :name, :food_column, :base_output_per_day, :build_cost, :required_tech)

  CATALOG = [
    Building.new("plant_farm",     "Plant Farm",     :food_plants, 50, 2_500, "plant_farming"),
    Building.new("hunting_ground", "Hunting Ground", :food_meat,   40, 3_000, "hunting_grounds"),
    Building.new("fishing_pond",   "Fishing Pond",   :food_fish,   35, 3_000, "fishing_ponds")
  ].freeze

  INDEX = CATALOG.index_by(&:kind).freeze

  module_function

  def all = CATALOG

  def find(kind) = INDEX[kind.to_s]

  def kinds = INDEX.keys
end

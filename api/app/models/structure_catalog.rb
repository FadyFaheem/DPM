# Static catalog of buildable facilities. One of each kind per player. Each is
# gated by a research tech and grants a passive bonus once built: the vet lab
# enables treatment, the hatchery speeds breeding incubation, and the research
# station discounts research costs (see Economy / the relevant controllers).
module StructureCatalog
  Building = Data.define(:kind, :name, :cost, :required_tech)

  CATALOG = [
    Building.new("vet_lab",          "Veterinary Lab",   8_000, "veterinary"),
    Building.new("hatchery",         "Hatchery",         9_000, "genetic_trait_viewing"),
    Building.new("research_station", "Research Station", 10_000, "habitat_expansion")
  ].freeze

  INDEX = CATALOG.index_by(&:kind).freeze

  module_function

  def all = CATALOG

  def find(kind) = INDEX[kind.to_s]

  def kinds = INDEX.keys
end

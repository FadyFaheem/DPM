# Static catalog of unlockable technologies. Mirrors the immutable value-object
# pattern used by Species. Pay-to-unlock: prerequisites + an optional population
# milestone gate each tech; no research timers yet. Phase 3C grows the tree into
# three tiers and wires real effects (see `unlocks`):
#   - genetic_trait_viewing  -> build the hatchery structure
#   - mutation_rate_boost     -> Reproduction::Genetics raises mutation odds
#   - genetic_engineering_lab -> breeding can request a guaranteed offspring trait
#   - environmental_control   -> Simulation::Events softens event impact
#   - piscivore_unlock        -> acquire fish-eating (aquatic) species
#   - attractions             -> build passive-income theme-park attractions
module ResearchCatalog
  Tech = Data.define(
    :key, :name, :description, :cost, :prerequisites, :requires_population, :unlocks
  )

  CATALOG = [
    # Tier 1 -- foundational
    Tech.new("plant_farming",         "Plant Farming",          "Build plant farms that grow plant food over time.",        1_500, [],                        0, %w[plant_farm]),
    Tech.new("hunting_grounds",       "Hunting Grounds",        "Build hunting grounds that yield meat over time.",          2_000, [],                        0, %w[hunting_ground]),
    Tech.new("fishing_ponds",         "Fishing Ponds",          "Build fishing ponds that yield fish over time.",            2_000, [],                        0, %w[fishing_pond]),
    Tech.new("veterinary",            "Veterinary Science",     "Build a veterinary lab to treat and cure sick dinosaurs.",  2_500, [],                        0, %w[vet_lab]),
    Tech.new("genetic_trait_viewing", "Genetic Trait Viewing",  "Reveal genetics and build a hatchery for faster breeding.", 1_200, [],                        0, %w[trait_viewing hatchery]),
    # Tier 2 -- specialization
    Tech.new("advanced_farming",      "Advanced Farming",       "Upgrade food-production buildings past level 1.",           4_000, %w[plant_farming],          0, %w[food_production_upgrade]),
    Tech.new("habitat_expansion",     "Habitat Expansion",      "Upgrade habitats and build a research station.",            3_000, [],                        5, %w[habitat_upgrade research_station]),
    Tech.new("piscivore_unlock",      "Piscivore Husbandry",    "Acquire fish-eating species for aquatic habitats.",         4_000, %w[fishing_ponds],          0, %w[piscivore_species]),
    Tech.new("mutation_rate_boost",   "Mutation Rate Boost",    "Greatly raise the chance of mutations when breeding.",      4_500, %w[genetic_trait_viewing],  0, %w[mutation_boost]),
    Tech.new("attractions",           "Theme-Park Attractions", "Build attractions that earn passive currency over time.",   5_000, [],                        6, %w[attractions]),
    # Tier 3 -- mastery
    Tech.new("environmental_control", "Environmental Control",  "Soften the impact of droughts, floods, and heat spikes.",   6_000, %w[habitat_expansion],      0, %w[effect_mitigation]),
    Tech.new("genetic_engineering_lab", "Genetic Engineering Lab", "Choose a guaranteed mutation for bred offspring.",       9_000, %w[genetic_trait_viewing mutation_rate_boost], 0, %w[trait_selection])
  ].freeze

  INDEX = CATALOG.index_by(&:key).freeze

  module_function

  def all = CATALOG

  def find(key) = INDEX[key.to_s]

  def keys = INDEX.keys
end

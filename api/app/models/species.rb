# Static species catalog. Each entry is an immutable value object describing
# fixed traits plus the gates to acquire a live specimen (Phase 3C): a currency
# `acquire_cost`, an optional `required_tech` (e.g. piscivores need the
# piscivore_unlock research), and an optional `requires_population` milestone.
# Starters are always unlocked; every other species is acquired on demand.
module Species
  Entry = Data.define(
    :key, :name, :period, :diet_primary, :diet_secondary,
    :preferred_terrain, :social_structure, :base_size_lbs, :rarity, :starter,
    :acquire_cost, :required_tech, :requires_population
  )

  CATALOG = [
    # Triassic
    Entry.new("coelophysis",     "Coelophysis",     "Triassic",   "meat",   nil,       "forest",    "solitary",      60, :common,   false, 1_500, nil,               0),
    Entry.new("plateosaurus",    "Plateosaurus",    "Triassic",   "plants", nil,       "forest",    "herd",       4_000, :common,   false, 1_500, nil,               0),
    Entry.new("herrerasaurus",   "Herrerasaurus",   "Triassic",   "meat",   "insects", "grassland", "pair",         500, :uncommon, false, 3_500, nil,               0),
    # Jurassic
    Entry.new("stegosaurus",     "Stegosaurus",     "Jurassic",   "plants", nil,       "forest",    "herd",      11_000, :common,   true,  1_500, nil,               0),
    Entry.new("brachiosaurus",   "Brachiosaurus",   "Jurassic",   "plants", nil,       "grassland", "herd",      62_000, :uncommon, false, 3_500, nil,               0),
    Entry.new("dilophosaurus",   "Dilophosaurus",   "Jurassic",   "meat",   "fish",    "forest",    "pair",         900, :uncommon, false, 3_500, nil,               0),
    Entry.new("allosaurus",      "Allosaurus",      "Jurassic",   "meat",   "insects", "grassland", "pair",       4_000, :rare,     false, 7_000, nil,               0),
    # Cretaceous
    Entry.new("triceratops",     "Triceratops",     "Cretaceous", "plants", "insects", "grassland", "herd",      13_000, :common,   true,  1_500, nil,               0),
    Entry.new("velociraptor",    "Velociraptor",    "Cretaceous", "meat",   "insects", "grassland", "pair",          35, :common,   true,  1_500, nil,               0),
    Entry.new("parasaurolophus", "Parasaurolophus", "Cretaceous", "plants", "insects", "wetland",   "herd",       5_000, :common,   false, 1_500, nil,               0),
    Entry.new("ankylosaurus",    "Ankylosaurus",    "Cretaceous", "plants", nil,       "forest",    "solitary",  16_000, :uncommon, false, 3_500, nil,               0),
    Entry.new("tyrannosaurus",   "Tyrannosaurus",   "Cretaceous", "meat",   nil,       "grassland", "solitary",  16_000, :rare,     false, 7_000, nil,               8),
    Entry.new("pteranodon",      "Pteranodon",      "Cretaceous", "fish",   nil,       "aquatic",   "pair",          50, :uncommon, false, 3_500, "piscivore_unlock", 0),
    Entry.new("spinosaurus",     "Spinosaurus",     "Cretaceous", "fish",   "meat",    "aquatic",   "solitary",  16_000, :rare,     false, 7_000, "piscivore_unlock", 0)
  ].freeze

  PERIODS = CATALOG.map(&:period).uniq.freeze

  INDEX = CATALOG.index_by(&:key).freeze

  module_function

  def all = CATALOG

  def find(key) = INDEX[key.to_s]

  def starters = CATALOG.select(&:starter)

  def keys = INDEX.keys

  def adjacent?(key_a, key_b)
    a = find(key_a)
    b = find(key_b)
    return false unless a && b

    a.key == b.key || (a.diet_primary == b.diet_primary && a.period == b.period)
  end
end

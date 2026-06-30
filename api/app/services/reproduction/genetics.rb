# Pure-ish genetics helpers (RNG injected for deterministic tests).
module Reproduction
  module Genetics
    MUTATIONS = %w[shiny giant dwarf].freeze
    MUTATION_CHANCE = 0.08
    DIET_INHERIT_CHANCE = 0.8
    GIANT_FACTOR = 1.2
    DWARF_FACTOR = 0.8

    module_function

    def roll_mutations(rng = Random.new)
      return [] if rng.rand >= MUTATION_CHANCE

      [ MUTATIONS.sample(random: rng) ]
    end

    def size_with_mutations(base_size, mutations)
      size = base_size
      size = (size * GIANT_FACTOR).round if mutations.include?("giant")
      size = (size * DWARF_FACTOR).round if mutations.include?("dwarf")
      size
    end

    def inherit_diet(parent_a, parent_b, rng = Random.new)
      if rng.rand < DIET_INHERIT_CHANCE
        [ parent_a.diet_primary, parent_b.diet_primary ].sample(random: rng)
      else
        Dinosaur::DIETS.sample(random: rng) # rare new-diet mutation
      end
    end

    def inherit_color(parent_a, parent_b, mutations, rng = Random.new)
      return "iridescent" if mutations.include?("shiny")

      [ parent_a.color, parent_b.color ].compact.sample(random: rng) || DinoFactory::COLORS.sample(random: rng)
    end
  end
end

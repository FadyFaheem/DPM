# Whether two dinosaurs may breed. Returns a human-readable reason when they
# can't, or nil when the pairing is allowed.
module Reproduction
  module Compatibility
    MIN_HEALTH = 60

    module_function

    def reason(parent_a, parent_b)
      return "Both dinosaurs must be alive" unless parent_a.alive && parent_b.alive
      return "A breeding pair must be opposite genders" if parent_a.gender == parent_b.gender
      return "Both need at least #{MIN_HEALTH} health to breed" if below_min_health?(parent_a, parent_b)
      return "These species are not compatible" unless Species.adjacent?(parent_a.species, parent_b.species)

      nil
    end

    def compatible?(parent_a, parent_b)
      reason(parent_a, parent_b).nil?
    end

    def below_min_health?(parent_a, parent_b)
      parent_a.health < MIN_HEALTH || parent_b.health < MIN_HEALTH
    end
  end
end

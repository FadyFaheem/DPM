require "rails_helper"

RSpec.describe Reproduction::Genetics do
  describe ".size_with_mutations" do
    it "enlarges giants and shrinks dwarves" do
      expect(described_class.size_with_mutations(100, [ "giant" ])).to eq(120)
      expect(described_class.size_with_mutations(100, [ "dwarf" ])).to eq(80)
      expect(described_class.size_with_mutations(100, [])).to eq(100)
    end
  end

  describe ".roll_mutations" do
    it "returns at most one mutation, drawn from the valid set" do
      result = described_class.roll_mutations(Random.new(42))
      expect(result.size).to be <= 1
      expect(result - described_class::MUTATIONS).to be_empty
    end

    it "never mutates at chance 0 and always mutates at chance 1" do
      expect(described_class.roll_mutations(Random.new(1), chance: 0.0)).to eq([])
      expect(described_class.roll_mutations(Random.new(1), chance: 1.0).size).to eq(1)
    end

    it "mutates more often at the boosted chance than the base chance for the same seed" do
      # A seed whose first roll lands between the base and boosted thresholds:
      # rejected at the base rate but accepted once mutation_rate_boost applies.
      seed = (1..500).find do |s|
        roll = Random.new(s).rand
        roll >= described_class::MUTATION_CHANCE && roll < described_class::BOOSTED_MUTATION_CHANCE
      end

      expect(described_class.roll_mutations(Random.new(seed))).to eq([])
      expect(described_class.roll_mutations(Random.new(seed), chance: described_class::BOOSTED_MUTATION_CHANCE).size).to eq(1)
    end
  end

  describe ".inherit_color" do
    it "is iridescent for a shiny mutation" do
      a = instance_double(Dinosaur, color: "amber")
      b = instance_double(Dinosaur, color: "slate")
      expect(described_class.inherit_color(a, b, [ "shiny" ], Random.new(1))).to eq("iridescent")
    end
  end
end

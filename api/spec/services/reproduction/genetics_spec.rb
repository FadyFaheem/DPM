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
  end

  describe ".inherit_color" do
    it "is iridescent for a shiny mutation" do
      a = instance_double(Dinosaur, color: "amber")
      b = instance_double(Dinosaur, color: "slate")
      expect(described_class.inherit_color(a, b, [ "shiny" ], Random.new(1))).to eq("iridescent")
    end
  end
end

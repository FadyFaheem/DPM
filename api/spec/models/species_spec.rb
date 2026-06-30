require "rails_helper"

RSpec.describe Species do
  it "spans the three geologic periods" do
    expect(described_class.all.map(&:period).uniq).to contain_exactly("Triassic", "Jurassic", "Cretaceous")
  end

  it "includes at least one piscivore (fish diet) for aquatic habitats" do
    piscivores = described_class.all.select { |s| s.diet_primary == "fish" }
    expect(piscivores).not_to be_empty
    expect(piscivores).to all(have_attributes(preferred_terrain: "aquatic"))
  end

  it "gates piscivores behind the piscivore_unlock research" do
    expect(described_class.find("spinosaurus").required_tech).to eq("piscivore_unlock")
  end

  it "exposes acquisition gates on every entry" do
    expect(described_class.all).to all(have_attributes(acquire_cost: be > 0))
  end

  it "keeps the original starters" do
    expect(described_class.starters.map(&:key)).to contain_exactly("triceratops", "stegosaurus", "velociraptor")
  end

  it "looks up by key and returns nil for an unknown key" do
    expect(described_class.find("tyrannosaurus").name).to eq("Tyrannosaurus")
    expect(described_class.find("smaug")).to be_nil
  end

  it "treats same-diet, same-period species as breeding-adjacent" do
    expect(described_class.adjacent?("tyrannosaurus", "velociraptor")).to be(true) # both Cretaceous meat
    expect(described_class.adjacent?("tyrannosaurus", "stegosaurus")).to be(false)
  end
end

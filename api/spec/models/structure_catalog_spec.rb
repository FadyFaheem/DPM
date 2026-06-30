require "rails_helper"

RSpec.describe StructureCatalog do
  it "includes the veterinary lab gated by veterinary research" do
    vet = described_class.find("vet_lab")
    expect(vet.required_tech).to eq("veterinary")
    expect(vet.cost).to be > 0
  end

  it "adds a hatchery gated by genetic trait viewing" do
    expect(described_class.find("hatchery").required_tech).to eq("genetic_trait_viewing")
  end

  it "adds a research station gated by habitat expansion" do
    expect(described_class.find("research_station").required_tech).to eq("habitat_expansion")
  end

  it "returns nil for an unknown structure" do
    expect(described_class.find("space_elevator")).to be_nil
  end
end

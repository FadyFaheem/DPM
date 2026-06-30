require "rails_helper"

RSpec.describe AttractionCatalog do
  it "lists attractions, all gated by the attractions research" do
    expect(described_class.all).not_to be_empty
    expect(described_class.all).to all(have_attributes(required_tech: "attractions"))
  end

  it "exposes positive income and build cost per attraction" do
    expect(described_class.all).to all(have_attributes(income_per_day: be > 0, build_cost: be > 0))
  end

  it "looks up by kind and returns nil for an unknown kind" do
    expect(described_class.find("carousel").name).to eq("Dino Carousel")
    expect(described_class.find("rollercoaster")).to be_nil
  end
end

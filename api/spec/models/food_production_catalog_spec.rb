require "rails_helper"

RSpec.describe FoodProductionCatalog do
  it "maps each building kind to a food store and required tech" do
    farm = described_class.find("plant_farm")
    expect(farm.food_column).to eq(:food_plants)
    expect(farm.required_tech).to eq("plant_farming")
    expect(farm.base_output_per_day).to be > 0
  end

  it "covers all three food stores" do
    columns = described_class.all.map(&:food_column)
    expect(columns).to contain_exactly(:food_plants, :food_meat, :food_fish)
  end

  it "returns nil for an unknown kind" do
    expect(described_class.find("oil_rig")).to be_nil
  end
end

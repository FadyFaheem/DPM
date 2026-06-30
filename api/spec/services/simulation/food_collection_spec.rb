require "rails_helper"

RSpec.describe Simulation::FoodCollection do
  # Default scale: 60 real minutes == 1 game-day, so 10 real hours == 10 game-days.
  let(:player) { Player.create!(player_code: PlayerCode.generate, display_name: "K", food_plants: 0, food_meat: 0, food_fish: 0) }

  it "accrues output per game-day into the matching food store" do
    player.food_productions.create!(kind: "plant_farm", level: 1, last_collected_at: 10.hours.ago)

    described_class.call(player, now: Time.current)

    expect(player.reload.food_plants).to eq(10 * FoodProductionCatalog.find("plant_farm").base_output_per_day)
  end

  it "scales output with the building level" do
    player.food_productions.create!(kind: "plant_farm", level: 3, last_collected_at: 5.hours.ago)

    described_class.call(player, now: Time.current)

    expect(player.reload.food_plants).to eq(5 * 3 * 50)
  end

  it "routes each building kind to its own food store" do
    player.food_productions.create!(kind: "hunting_ground", last_collected_at: 4.hours.ago)
    player.food_productions.create!(kind: "fishing_pond", last_collected_at: 4.hours.ago)

    described_class.call(player, now: Time.current)

    player.reload
    expect(player.food_meat).to eq(4 * 40)
    expect(player.food_fish).to eq(4 * 35)
    expect(player.food_plants).to eq(0)
  end

  it "accrues nothing within the same game-day and keeps the remainder" do
    building = player.food_productions.create!(kind: "plant_farm", last_collected_at: 30.minutes.ago)
    collected_before = building.last_collected_at

    described_class.call(player, now: Time.current)

    expect(player.reload.food_plants).to eq(0)
    expect(building.reload.last_collected_at).to be_within(1.second).of(collected_before)
  end
end

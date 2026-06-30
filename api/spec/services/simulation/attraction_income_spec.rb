require "rails_helper"

RSpec.describe Simulation::AttractionIncome do
  # Default scale: 60 real minutes == 1 game-day, so 10 real hours == 10 game-days.
  let(:player) { Player.create!(player_code: PlayerCode.generate, display_name: "K", currency: 0) }

  it "credits income for each whole game-day" do
    player.attractions.create!(kind: "carousel", level: 1, last_collected_at: 10.hours.ago)

    described_class.call(player, now: Time.current)

    expect(player.reload.currency).to eq(10 * AttractionCatalog.find("carousel").income_per_day)
  end

  it "scales income with the attraction level" do
    player.attractions.create!(kind: "museum", level: 3, last_collected_at: 5.hours.ago)

    described_class.call(player, now: Time.current)

    expect(player.reload.currency).to eq(5 * 3 * AttractionCatalog.find("museum").income_per_day)
  end

  it "pays nothing within the same game-day and keeps the remainder" do
    attraction = player.attractions.create!(kind: "carousel", last_collected_at: 30.minutes.ago)
    collected_before = attraction.last_collected_at

    described_class.call(player, now: Time.current)

    expect(player.reload.currency).to eq(0)
    expect(attraction.reload.last_collected_at).to be_within(1.second).of(collected_before)
  end

  it "advances the watermark by whole game-days only, carrying the remainder" do
    attraction = player.attractions.create!(kind: "carousel", last_collected_at: 3.5.hours.ago)
    since = attraction.last_collected_at

    described_class.call(player, now: Time.current)

    expect(attraction.reload.last_collected_at).to be_within(1.second).of(since + 3.hours)
  end
end

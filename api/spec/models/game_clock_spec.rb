require "rails_helper"

RSpec.describe GameClock do
  describe ".game_days_between" do
    it "treats one real hour as one game day at the default scale" do
      from = Time.current
      expect(described_class.game_days_between(from, from + 3600)).to be_within(0.001).of(1.0)
    end

    it "is zero when an endpoint is nil" do
      expect(described_class.game_days_between(nil, Time.current)).to eq(0.0)
    end
  end

  describe ".age_months" do
    it "converts 30 game days into one game month" do
      born = Time.current
      expect(described_class.age_months(born, born + (30 * 3600))).to be_within(0.001).of(1.0)
    end
  end

  describe ".real_seconds_for_game_days" do
    it "is the inverse of game_days_between" do
      from = Time.current
      seconds = described_class.real_seconds_for_game_days(2)
      expect(described_class.game_days_between(from, from + seconds)).to be_within(0.001).of(2.0)
    end
  end
end

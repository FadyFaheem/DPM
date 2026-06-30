require "rails_helper"

RSpec.describe SpeciesUnlock do
  let(:player) { Player.create!(player_code: PlayerCode.generate, display_name: "K") }

  it "records a valid species key" do
    unlock = player.species_unlocks.create(species_key: "tyrannosaurus")
    expect(unlock).to be_persisted
  end

  it "rejects an unknown species key" do
    unlock = player.species_unlocks.build(species_key: "smaug")
    expect(unlock).not_to be_valid
  end

  it "is unique per player + species" do
    player.species_unlocks.create!(species_key: "tyrannosaurus")
    dup = player.species_unlocks.build(species_key: "tyrannosaurus")
    expect(dup).not_to be_valid
  end
end

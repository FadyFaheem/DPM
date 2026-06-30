require "rails_helper"

RSpec.describe Reproduction::Compatibility do
  let(:player) { Player.create!(player_code: PlayerCode.generate, display_name: "K") }

  def dino(species: "triceratops", **overrides)
    player.dinosaurs.create!(
      DinoFactory.attributes_for(Species.find(species), player:, habitat: nil).merge(overrides)
    )
  end

  it "allows a healthy, opposite-gender, same-species pair" do
    a = dino(gender: "male", health: 80)
    b = dino(gender: "female", health: 80)
    expect(described_class.reason(a, b)).to be_nil
    expect(described_class).to be_compatible(a, b)
  end

  it "rejects a same-gender pair" do
    expect(described_class.reason(dino(gender: "male"), dino(gender: "male"))).to match(/opposite genders/)
  end

  it "rejects low health" do
    a = dino(gender: "male", health: 50)
    b = dino(gender: "female", health: 80)
    expect(described_class.reason(a, b)).to match(/health/)
  end

  it "rejects incompatible species" do
    a = dino(gender: "male")
    b = dino(species: "velociraptor", gender: "female")
    expect(described_class.reason(a, b)).to match(/not compatible/)
  end

  it "rejects dead dinosaurs" do
    expect(described_class.reason(dino(gender: "male", alive: false), dino(gender: "female"))).to match(/alive/)
  end
end

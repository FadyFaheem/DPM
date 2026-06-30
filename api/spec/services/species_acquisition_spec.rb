require "rails_helper"

RSpec.describe SpeciesAcquisition do
  let(:player) { Player.create!(player_code: PlayerCode.generate, display_name: "K", currency: 50_000) }

  before { player.habitats.create!(name: "Plains", terrain: "grassland", capacity: 8) }

  it "spends currency, spawns a dino, and records the unlock" do
    cost = Species.find("ankylosaurus").acquire_cost

    expect { described_class.call(player, species_key: "ankylosaurus") }
      .to change { player.dinosaurs.count }.by(1)
      .and change { player.species_unlocks.count }.by(1)

    expect(player.reload.currency).to eq(50_000 - cost)
    expect(player.species_unlocks.pluck(:species_key)).to include("ankylosaurus")
  end

  it "logs an acquire event" do
    expect { described_class.call(player, species_key: "ankylosaurus") }
      .to change { player.events.where(kind: "acquire").count }.by(1)
  end

  it "places the dino in a habitat that matches its preferred terrain when possible" do
    player.habitats.create!(name: "Lake", terrain: "aquatic", capacity: 4)
    player.researches.create!(tech_key: "piscivore_unlock")

    dino = described_class.call(player, species_key: "spinosaurus")

    expect(dino.habitat.terrain).to eq("aquatic")
  end

  it "does not re-record an unlock on a second acquisition" do
    described_class.call(player, species_key: "ankylosaurus")

    expect { described_class.call(player, species_key: "ankylosaurus") }
      .to change { player.dinosaurs.count }.by(1)
    expect(player.species_unlocks.where(species_key: "ankylosaurus").count).to eq(1)
  end

  it "refuses an unknown species" do
    expect { described_class.call(player, species_key: "smaug") }
      .to raise_error(described_class::Error, /Unknown/)
  end

  it "refuses when the player cannot afford it" do
    player.update!(currency: 10)
    expect { described_class.call(player, species_key: "allosaurus") }
      .to raise_error(described_class::Error, /currency/)
    expect(player.dinosaurs.count).to eq(0)
  end

  it "requires the gating research for a piscivore" do
    expect { described_class.call(player, species_key: "spinosaurus") }
      .to raise_error(described_class::Error, /piscivore_unlock/)
  end

  it "allows a piscivore once the research is unlocked" do
    player.researches.create!(tech_key: "piscivore_unlock")
    expect { described_class.call(player, species_key: "spinosaurus") }
      .to change { player.dinosaurs.count }.by(1)
  end

  it "enforces a population milestone" do
    expect { described_class.call(player, species_key: "tyrannosaurus") }
      .to raise_error(described_class::Error, /living dinosaurs/)
  end
end

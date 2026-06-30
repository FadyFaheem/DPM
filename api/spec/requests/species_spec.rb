require "rails_helper"

RSpec.describe "Api::Species", type: :request do
  let(:player) { Player.create!(player_code: PlayerCode.generate, display_name: "K", currency: 50_000) }
  let(:headers) { { "Authorization" => "Bearer #{player.player_code}" } }

  before { player.habitats.create!(name: "Plains", terrain: "grassland", capacity: 8) }

  describe "GET /api/species" do
    it "returns the catalog with unlocked and owned flags" do
      player.species_unlocks.create!(species_key: "ankylosaurus")
      get "/api/species", headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["periods"]).to include("Triassic", "Jurassic", "Cretaceous")

      starter = body["catalog"].find { |s| s["key"] == "triceratops" }
      expect(starter["unlocked"]).to be(true)

      anky = body["catalog"].find { |s| s["key"] == "ankylosaurus" }
      expect(anky["unlocked"]).to be(true)

      locked = body["catalog"].find { |s| s["key"] == "tyrannosaurus" }
      expect(locked["unlocked"]).to be(false)
    end

    it "requires a player code" do
      get "/api/species"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/species" do
    it "acquires a dino and charges currency" do
      cost = Species.find("ankylosaurus").acquire_cost

      expect do
        post "/api/species", params: { species_key: "ankylosaurus" }, headers: headers
      end.to change { player.dinosaurs.count }.by(1)

      expect(response).to have_http_status(:created)
      expect(player.reload.currency).to eq(50_000 - cost)
    end

    it "rejects an unknown species" do
      post "/api/species", params: { species_key: "smaug" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "rejects a piscivore without the gating research" do
      post "/api/species", params: { species_key: "spinosaurus" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to match(/piscivore_unlock/)
    end

    it "rejects an apex predator below the population milestone" do
      post "/api/species", params: { species_key: "tyrannosaurus" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to match(/living dinosaurs/)
    end

    it "requires a player code" do
      post "/api/species", params: { species_key: "ankylosaurus" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

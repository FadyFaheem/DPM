require "rails_helper"

RSpec.describe "Api::FoodProductions", type: :request do
  let(:player) { Player.create!(player_code: PlayerCode.generate, display_name: "K", currency: 20_000) }
  let(:headers) { { "Authorization" => "Bearer #{player.player_code}" } }

  def unlock(tech) = player.researches.create!(tech_key: tech)

  describe "POST /api/food_productions" do
    it "builds a farm when its tech is unlocked and charges currency" do
      unlock("plant_farming")

      expect do
        post "/api/food_productions", params: { kind: "plant_farm" }, headers: headers
      end.to change(player.food_productions, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(player.reload.currency).to eq(20_000 - FoodProductionCatalog.find("plant_farm").build_cost)
    end

    it "refuses to build without the required research" do
      post "/api/food_productions", params: { kind: "plant_farm" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(player.food_productions.count).to eq(0)
    end

    it "rejects an unknown building kind" do
      post "/api/food_productions", params: { kind: "oil_rig" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "requires a player code" do
      post "/api/food_productions", params: { kind: "plant_farm" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/food_productions/:id/upgrade" do
    it "raises the level when advanced_farming is unlocked" do
      unlock("plant_farming")
      unlock("advanced_farming")
      building = player.food_productions.create!(kind: "plant_farm", last_collected_at: Time.current)

      post "/api/food_productions/#{building.id}/upgrade", headers: headers

      expect(response).to have_http_status(:ok)
      expect(building.reload.level).to eq(2)
      expect(player.reload.currency).to eq(20_000 - Economy.food_production_upgrade_cost(1))
    end

    it "refuses to upgrade without advanced_farming" do
      unlock("plant_farming")
      building = player.food_productions.create!(kind: "plant_farm", last_collected_at: Time.current)

      post "/api/food_productions/#{building.id}/upgrade", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(building.reload.level).to eq(1)
    end
  end

  describe "GET /api/food_productions" do
    it "returns built buildings and the catalog with unlocked flags" do
      unlock("plant_farming")
      player.food_productions.create!(kind: "plant_farm", last_collected_at: Time.current)

      get "/api/food_productions", headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["buildings"].size).to eq(1)
      plant = body["catalog"].find { |c| c["kind"] == "plant_farm" }
      expect(plant["unlocked"]).to be(true)
    end
  end
end

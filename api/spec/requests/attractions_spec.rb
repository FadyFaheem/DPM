require "rails_helper"

RSpec.describe "Api::Attractions", type: :request do
  let(:player) { Player.create!(player_code: PlayerCode.generate, display_name: "K", currency: 50_000) }
  let(:headers) { { "Authorization" => "Bearer #{player.player_code}" } }

  describe "GET /api/attractions" do
    it "returns the catalog with unlocked flags" do
      get "/api/attractions", headers: headers

      expect(response).to have_http_status(:ok)
      carousel = JSON.parse(response.body)["catalog"].find { |a| a["kind"] == "carousel" }
      expect(carousel["unlocked"]).to be(false)
    end

    it "requires a player code" do
      get "/api/attractions"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/attractions" do
    it "builds an attraction when researched and charges currency" do
      player.researches.create!(tech_key: "attractions")

      expect do
        post "/api/attractions", params: { kind: "carousel" }, headers: headers
      end.to change(player.attractions, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(player.reload.currency).to eq(50_000 - AttractionCatalog.find("carousel").build_cost)
    end

    it "refuses to build without the attractions research" do
      post "/api/attractions", params: { kind: "carousel" }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(player.attractions.count).to eq(0)
    end

    it "refuses to build the same attraction twice" do
      player.researches.create!(tech_key: "attractions")
      player.attractions.create!(kind: "carousel", last_collected_at: Time.current)

      post "/api/attractions", params: { kind: "carousel" }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "requires a player code" do
      post "/api/attractions", params: { kind: "carousel" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/attractions/:id/upgrade" do
    it "raises the level and charges the upgrade cost" do
      player.attractions.create!(kind: "carousel", level: 1, last_collected_at: Time.current)
      attraction = player.attractions.first
      cost = Economy.attraction_upgrade_cost(1)

      post "/api/attractions/#{attraction.id}/upgrade", headers: headers

      expect(response).to have_http_status(:ok)
      expect(attraction.reload.level).to eq(2)
      expect(player.reload.currency).to eq(50_000 - cost)
    end
  end
end

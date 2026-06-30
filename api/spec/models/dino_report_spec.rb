require "rails_helper"

RSpec.describe DinoReport do
  let(:dino_data) do
    [
      { "name" => "DinoA", "category" => "herbivore", "period" => "Cretaceous", "diet" => "plants", "age" => 100 },
      { "name" => "DinoB", "category" => "carnivore", "period" => "Jurassic", "diet" => "meat", "age" => 80 }
    ]
  end

  subject(:result) { described_class.call(dino_data) }

  describe "dino health calculation" do
    it "calculates health from age, category and diet" do
      a, b = result[:dinos]
      expect(a["health"]).to eq(0)  # 100 - 100
      expect(b["health"]).to eq(20) # 100 - 80, diet matches
    end

    it "halves health on a diet mismatch" do
      mismatched = [ { "name" => "X", "category" => "herbivore", "diet" => "meat", "age" => 80 } ]
      expect(described_class.call(mismatched)[:dinos].first["health"]).to eq(10) # (100 - 80) / 2
    end

    it "is zero for a non-positive age" do
      old = [ { "name" => "Z", "category" => "herbivore", "diet" => "plants", "age" => 0 } ]
      expect(described_class.call(old)[:dinos].first["health"]).to eq(0)
    end
  end

  describe "dino comment setting" do
    it "assigns appropriate comment based on health" do
      a, b = result[:dinos]
      expect(a["comment"]).to eq("Dead")  # health 0
      expect(b["comment"]).to eq("Alive") # health 20
    end
  end

  describe "dino age metric calculation" do
    it "computes age_metrics based on age and comment" do
      a, b = result[:dinos]
      expect(a["age_metrics"]).to eq(0)  # dead -> 0
      expect(b["age_metrics"]).to eq(40) # alive, 80 / 2
    end
  end

  describe "dino category summary" do
    it "counts dinos by categories" do
      expect(result[:summary]).to eq("herbivore" => 1, "carnivore" => 1)
    end
  end

  describe "robustness" do
    it "handles an empty list" do
      expect(described_class.call([])).to eq(dinos: [], summary: {})
    end

    it "does not mutate the input" do
      described_class.call(dino_data)
      expect(dino_data.first).not_to have_key("health")
    end
  end
end

module Api
  class AttractionsController < BaseController
    # GET /api/attractions
    def index
      render json: GameSerializer.attractions(current_player)
    end

    # POST /api/attractions { kind }
    def create
      spec = AttractionCatalog.find(params[:kind])
      return render json: { error: "Unknown attraction" }, status: :unprocessable_entity unless spec
      unless current_player.researches.exists?(tech_key: spec.required_tech)
        return render json: { error: "Requires #{spec.required_tech}" }, status: :unprocessable_entity
      end
      if current_player.attractions.exists?(kind: spec.kind)
        return render json: { error: "Already built" }, status: :unprocessable_entity
      end
      if current_player.currency < spec.build_cost
        return render json: { error: "Not enough currency" }, status: :unprocessable_entity
      end

      current_player.transaction do
        current_player.update!(currency: current_player.currency - spec.build_cost)
        current_player.attractions.create!(kind: spec.kind, last_collected_at: Time.current)
        Event.log(current_player, "build", "Built #{spec.name}")
      end

      render json: GameSerializer.attractions(current_player), status: :created
    end

    # POST /api/attractions/:id/upgrade
    def upgrade
      attraction = current_player.attractions.find_by(id: params[:id])
      return render json: { error: "Attraction not found" }, status: :not_found unless attraction

      cost = Economy.attraction_upgrade_cost(attraction.level)
      if current_player.currency < cost
        return render json: { error: "Not enough currency" }, status: :unprocessable_entity
      end

      spec = AttractionCatalog.find(attraction.kind)
      current_player.transaction do
        # Settle income earned at the current level before raising it.
        Simulation::AttractionIncome.call(current_player)
        current_player.update!(currency: current_player.currency - cost)
        attraction.reload
        attraction.update!(level: attraction.level + 1)
        Event.log(current_player, "upgrade", "Upgraded #{spec.name} to level #{attraction.level}")
      end

      render json: GameSerializer.attractions(current_player)
    end
  end
end

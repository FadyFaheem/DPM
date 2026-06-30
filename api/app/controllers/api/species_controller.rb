module Api
  class SpeciesController < BaseController
    # GET /api/species -- catalog with per-player unlocked/owned flags.
    def index
      render json: GameSerializer.species(current_player)
    end

    # POST /api/species { species_key } -- acquire a live dino of a species.
    def create
      SpeciesAcquisition.call(current_player, species_key: params[:species_key])
      render json: GameSerializer.species(current_player), status: :created
    rescue SpeciesAcquisition::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end

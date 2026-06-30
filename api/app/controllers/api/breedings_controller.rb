module Api
  class BreedingsController < BaseController
    INCUBATION_GAME_DAYS = 2

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Dinosaur or breeding not found" }, status: :not_found
    end

    # GET /api/breedings
    def index
      render json: current_player.breedings.order(created_at: :desc).map { |b| breeding_json(b) }
    end

    # POST /api/breedings { parent_a_id, parent_b_id }
    def create
      parent_a = current_player.dinosaurs.find(params[:parent_a_id])
      parent_b = current_player.dinosaurs.find(params[:parent_b_id])
      Simulation::DinoTick.call(parent_a)
      Simulation::DinoTick.call(parent_b)

      reason = Reproduction::Compatibility.reason(parent_a, parent_b)
      return render json: { error: reason }, status: :unprocessable_entity if reason
      return render json: { error: "Not enough currency" }, status: :unprocessable_entity if current_player.currency < Economy::BREEDING_COST

      breeding = start_breeding(parent_a, parent_b)
      render json: breeding_json(breeding), status: :created
    end

    # POST /api/breedings/:id/claim
    def claim
      breeding = current_player.breedings.find(params[:id])
      return render json: { error: "This breeding was already claimed" }, status: :unprocessable_entity unless breeding.status == "incubating"
      return render json: { error: "Still incubating" }, status: :unprocessable_entity unless breeding.ready?

      offspring = Reproduction::Hatch.call(breeding)
      render json: GameSerializer.dinosaur(offspring), status: :created
    end

    private

    def start_breeding(parent_a, parent_b)
      current_player.transaction do
        current_player.update!(currency: current_player.currency - Economy::BREEDING_COST)
        current_player.breedings.create!(
          parent_a: parent_a,
          parent_b: parent_b,
          hatches_at: Time.current + GameClock.real_seconds_for_game_days(INCUBATION_GAME_DAYS),
          status: "incubating"
        )
      end
    end

    def breeding_json(breeding)
      {
        id: breeding.id,
        status: breeding.status,
        parent_a_id: breeding.parent_a_id,
        parent_b_id: breeding.parent_b_id,
        offspring_id: breeding.offspring_id,
        hatches_at: breeding.hatches_at.utc.iso8601,
        ready: breeding.ready?,
        created_at: breeding.created_at.utc.iso8601
      }
    end
  end
end

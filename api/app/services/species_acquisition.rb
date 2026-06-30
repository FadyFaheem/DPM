# Acquires (buys + spawns) a live dinosaur of a catalog species for a player
# (Phase 3C). Gated by currency plus the species' optional research tech and
# population milestone. The first acquisition of a non-starter species records a
# SpeciesUnlock so the catalog can flag it as unlocked thereafter.
class SpeciesAcquisition
  class Error < StandardError; end

  def self.call(player, species_key:, now: Time.current)
    new(player, species_key, now).call
  end

  def initialize(player, species_key, now)
    @player = player
    @species = Species.find(species_key)
    @now = now
  end

  def call
    raise Error, "Unknown species" unless @species

    validate!
    @player.transaction do
      @player.update!(currency: @player.currency - @species.acquire_cost)
      record_unlock
      dino = spawn_dino
      Event.log(@player, "acquire", "Acquired a #{@species.name}", now: @now)
      dino
    end
  end

  private

  def validate!
    if @species.required_tech && !@player.researches.exists?(tech_key: @species.required_tech)
      raise Error, "Requires #{@species.required_tech}"
    end
    if @species.requires_population.positive? && @player.dinosaurs.alive.count < @species.requires_population
      raise Error, "Requires #{@species.requires_population} living dinosaurs"
    end
    raise Error, "Not enough currency" if @player.currency < @species.acquire_cost
  end

  def record_unlock
    return if @species.starter

    @player.species_unlocks.find_or_create_by!(species_key: @species.key)
  end

  def spawn_dino
    @player.dinosaurs.create!(
      DinoFactory.attributes_for(@species, player: @player, habitat: preferred_habitat, now: @now)
    )
  end

  # Prefer a matching-terrain habitat with room, then any habitat with room, then
  # the first habitat (the keeper can relocate later), else no habitat at all.
  def preferred_habitat
    habitats = @player.habitats.to_a
    habitats.find { |h| h.terrain == @species.preferred_terrain && h.living_count < h.capacity } ||
      habitats.find { |h| h.living_count < h.capacity } ||
      habitats.first
  end
end

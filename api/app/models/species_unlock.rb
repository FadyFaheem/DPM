# Records that a player has unlocked a non-starter species (Phase 3C). The first
# time a species is acquired its key is recorded here, so the catalog can flag it
# as unlocked even after every specimen of that species dies.
class SpeciesUnlock < ApplicationRecord
  belongs_to :player

  validates :species_key, presence: true,
            inclusion: { in: ->(_) { Species.keys } },
            uniqueness: { scope: :player_id }
end

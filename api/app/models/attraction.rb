# A built theme-park attraction (Phase 3C). Earns passive currency over time,
# settled compute-on-read by Simulation::AttractionIncome against
# `last_collected_at`. One of each kind per player; level scales income.
class Attraction < ApplicationRecord
  belongs_to :player

  validates :kind, presence: true,
            inclusion: { in: ->(_) { AttractionCatalog.kinds } },
            uniqueness: { scope: :player_id }
  validates :level, numericality: { only_integer: true, greater_than: 0 }
end

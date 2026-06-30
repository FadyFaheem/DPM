class FoodProduction < ApplicationRecord
  belongs_to :player

  validates :kind, presence: true, inclusion: { in: ->(_) { FoodProductionCatalog.kinds } }
  validates :level, numericality: { only_integer: true, greater_than: 0 }
end

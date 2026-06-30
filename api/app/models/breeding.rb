class Breeding < ApplicationRecord
  belongs_to :player
  belongs_to :parent_a, class_name: "Dinosaur"
  belongs_to :parent_b, class_name: "Dinosaur"
  belongs_to :offspring, class_name: "Dinosaur", optional: true

  STATUSES = %w[incubating hatched claimed].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :hatches_at, presence: true
  # Manual trait selection (genetic engineering lab); nil means roll naturally.
  validates :requested_trait, inclusion: { in: ->(_) { Reproduction::Genetics::MUTATIONS } }, allow_nil: true

  scope :incubating, -> { where(status: "incubating") }

  def ready?(now = Time.current)
    status == "incubating" && hatches_at <= now
  end
end

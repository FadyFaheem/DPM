class Player < ApplicationRecord
  has_many :habitats, dependent: :destroy
  has_many :dinosaurs, dependent: :destroy
  has_many :breedings, dependent: :destroy
  has_many :researches, dependent: :destroy
  has_many :food_productions, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :structures, dependent: :destroy
  has_many :active_effects, dependent: :destroy
  has_many :species_unlocks, dependent: :destroy
  has_many :attractions, dependent: :destroy

  # Maps a diet to the food store it draws from (insects forage from plants).
  FOOD_COLUMN = {
    "plants" => :food_plants, "insects" => :food_plants,
    "meat" => :food_meat, "fish" => :food_fish
  }.freeze

  validates :player_code, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :currency, :food_plants, :food_meat, :food_fish,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def food_for(diet)
    column = FOOD_COLUMN[diet]
    column ? public_send(column) : 0
  end

  def structure?(kind)
    structures.exists?(kind: kind)
  end

  # A species is available to acquire/breed once it is a starter or has been
  # unlocked (recorded in species_unlocks).
  def species_unlocked?(key)
    entry = Species.find(key)
    return false unless entry

    entry.starter || species_unlocks.exists?(species_key: entry.key)
  end
end

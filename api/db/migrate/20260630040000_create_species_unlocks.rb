class CreateSpeciesUnlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :species_unlocks do |t|
      t.references :player, null: false, foreign_key: true
      t.string :species_key, null: false

      t.timestamps
    end

    add_index :species_unlocks, [ :player_id, :species_key ], unique: true
  end
end

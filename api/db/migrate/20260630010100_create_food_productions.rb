class CreateFoodProductions < ActiveRecord::Migration[8.1]
  def change
    create_table :food_productions do |t|
      t.references :player, null: false, foreign_key: true
      t.string :kind, null: false
      t.integer :level, null: false, default: 1
      t.datetime :last_collected_at

      t.timestamps
    end

    add_index :food_productions, [ :player_id, :kind ]
  end
end

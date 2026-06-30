class AddRequestedTraitToBreedings < ActiveRecord::Migration[8.1]
  def change
    add_column :breedings, :requested_trait, :string
  end
end

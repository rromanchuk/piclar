class AddIndexOnPlaces < ActiveRecord::Migration
  def change
    add_index :places, [:latitude, :longitude]
  end
end

class CreatePlacesTable < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :title
      t.string :description
      t.string :city_name
      t.string :address
      t.string :phone
      t.integer :rating
      t.timestamps
    end
  end

  def down
  end
end

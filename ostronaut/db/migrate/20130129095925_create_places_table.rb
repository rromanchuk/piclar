class CreatePlacesTable < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :title
      t.string :city_name
      t.string :address
      t.string :phone
      t.integer :type
      t.string :type_text
      t.string :foursquare_id
      t.column "latitude", :decimal, :precision => 15, :scale => 10
      t.column "longitude", :decimal, :precision => 15, :scale => 10
      t.timestamps
    end
    add_index :places, :foursquare_id
  end
end

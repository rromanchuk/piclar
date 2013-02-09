class CreateFoursquareCategoriesTable < ActiveRecord::Migration
  def change
    create_table :foursquare_categories do |t|
      t.string :foursquare_id
      t.integer :parent_id
      t.string :name
      t.string :plural_name
      t.string :short_name
      t.string :icon
    end
    add_index :foursquare_categories :foursquare_id
    add_index :foursquare_categories :parent_id
  end
end

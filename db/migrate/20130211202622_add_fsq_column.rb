class AddFsqColumn < ActiveRecord::Migration
  def change
    add_column :places, :foursquare_category_id, :integer
    add_index :places, :foursquare_category_id
  end
end

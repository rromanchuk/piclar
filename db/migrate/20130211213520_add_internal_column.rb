class AddInternalColumn < ActiveRecord::Migration
  def change
    add_column :foursquare_categories, :internal_category_id, :integer, :limit => 1
  end
end

class AddUniqueKey < ActiveRecord::Migration
  def change
    change_column :foursquare_categories, :foursquare_id, :string, :unique => true
  end
end

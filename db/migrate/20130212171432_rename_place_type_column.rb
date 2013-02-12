class RenamePlaceTypeColumn < ActiveRecord::Migration
  def change
    rename_column :places, :type, :internal_type_id
  end
end

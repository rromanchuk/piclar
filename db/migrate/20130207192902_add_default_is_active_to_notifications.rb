class AddDefaultIsActiveToNotifications < ActiveRecord::Migration
  def change
     change_column :notifications, :is_active, :boolean, :default => true
  end
end

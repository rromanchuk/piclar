class CreateNotificationsTable < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.boolean :is_read
      t.string :notification_type
      t.boolean :is_active
      t.timestamps
    end
    add_index :notifications, :sender_id
    add_index :notifications, :receiver_id
  end
end

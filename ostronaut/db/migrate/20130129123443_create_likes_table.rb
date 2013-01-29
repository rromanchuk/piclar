class CreateLikesTable < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :user_id
      t.integer :feed_item_id
      t.timestamps
    end
    add_index :likes, :user_id
    add_index :likes, :feed_item_id
  end
end

class CreateFeedItemsTable < ActiveRecord::Migration
  def change
    create_table :feed_items do |t|
      t.integer :user_id
      t.integer :place_id
      t.integer :rating
      t.string :review
      t.timestamps
    end
    add_index :feed_items, :user_id
    add_index :feed_items, :place_id
  end
end

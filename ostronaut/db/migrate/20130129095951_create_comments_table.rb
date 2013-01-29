class CreateCommentsTable < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :feed_item_id

      t.string :comment
      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :feed_item_id
  end
end

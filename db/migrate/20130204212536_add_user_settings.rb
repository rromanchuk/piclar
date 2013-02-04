class AddUserSettings < ActiveRecord::Migration
  def change
    add_column :users, :push_comments, :boolean
    add_column :users, :push_posts, :boolean
    add_column :users, :push_likes, :boolean
    add_column :users, :push_friends, :boolean
    add_column :users, :save_filtered, :boolean
    add_column :users, :save_original, :boolean
  end
end

class AddUserSettings < ActiveRecord::Migration
  def change
    add_column :users, :push_comments, :boolean, :default => true
    add_column :users, :push_posts, :boolean, :default => true
    add_column :users, :push_likes, :boolean, :default => true
    add_column :users, :push_friends, :boolean, :default => true
    add_column :users, :save_filtered, :boolean, :default => true
    add_column :users, :save_original, :boolean, :default => true
  end
end

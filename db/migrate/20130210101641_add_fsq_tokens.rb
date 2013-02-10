class AddFsqTokens < ActiveRecord::Migration
  def change
    add_column :users, :fsq_token, :string
  end
end

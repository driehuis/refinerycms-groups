class AddUserTokenToUser < ActiveRecord::Migration
  def change
    add_column :refinery_users, :token, :string
  end
end

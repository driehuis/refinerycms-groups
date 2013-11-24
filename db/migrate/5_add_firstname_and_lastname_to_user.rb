class AddFirstnameAndLastnameToUser < ActiveRecord::Migration
  def change
    add_column :refinery_users, :first_name, :string
    add_column :refinery_users, :last_name, :string
  end
end

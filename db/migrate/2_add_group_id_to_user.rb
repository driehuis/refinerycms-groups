class AddGroupIdToUser < ActiveRecord::Migration
  def change
    add_column :refinery_users, :group_id, :integer
    add_index :refinery_users, :group_id
  end
end

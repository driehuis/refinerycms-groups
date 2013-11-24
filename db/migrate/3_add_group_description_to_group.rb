class AddGroupDescriptionToGroup < ActiveRecord::Migration
  def change
    add_column :refinery_groups, :description, :text
    add_column :refinery_groups, :expiration_date, :date
  end
end

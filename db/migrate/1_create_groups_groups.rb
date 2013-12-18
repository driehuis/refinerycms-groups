class CreateGroupsGroups < ActiveRecord::Migration

  def up
    create_table :refinery_groups do |t|
      t.string :name
      t.integer :position
      t.text :description
      t.date :expires_on
      t.integer :users_count, default: 0
      t.timestamps
    end

  end

  def down
    if defined?(::Refinery::UserPlugin)
      ::Refinery::UserPlugin.destroy_all({:name => "refinerycms-groups"})
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({:link_url => "/groups/groups"})
    end

    drop_table :refinery_groups

  end

end

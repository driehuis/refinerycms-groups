require 'haml-rails'
require 'acts_as_indexed'

module Refinery
  module Groups
    class Engine < Rails::Engine
      include Refinery::Engine
      isolate_namespace Refinery::Groups

      engine_name :refinery_groups

      initializer "register refinerycms_groups plugin" do
        Refinery::Plugin.register do |plugin|
          plugin.name = "groups"
          plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.groups_admin_groups_path }
          plugin.pathname = root
          plugin.activity = {
            :class_name => :'refinery/groups/group',
            :title => 'name'
          }
          
        end
      end
      
      config.to_prepare do
       Decorators.register! Gem::Specification.find_by_name("refinerycms-groups").gem_dir
      end

      config.after_initialize do
        Refinery.register_extension(Refinery::Groups)
      end
    end
  end
end

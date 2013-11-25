require 'spec_helper'

module Refinery
  module Groups
    module Admin
      describe UsersController do
        
        before do
          @group1 = create(:group, name: 'GroupSpec1', expires_on: 10.days.from_now)
          @group2 = create(:group, name: 'GroupSpec2', expires_on: 10.days.ago)
          5.times { |i| instance_variable_set("@user#{i}", create(:user))}
          @group1.add_users [@user1]
          @group2.add_users [@user2, @user3]
          @guests_group = Refinery::Groups::Group.guest_group
        end
        
        refinery_login_with :refinery_superuser
        
        describe "GET #index" do
          it "redirects to group show", :js => true do
            binding.pry
            get(:index, group_id: @group1.id)
            #response.should redirect_to refinery.groups_admin_group_path(@group1)
            response.should redirect_to "/refinery/groups/#{@group1.id}"
          end
        end
      end
    end
  end
end
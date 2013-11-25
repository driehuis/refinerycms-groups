# encoding: utf-8
require "spec_helper"

describe "Group management :" do
  
  before do
    @group1 = create(:group, name: 'GroupSpec1', expiration_date: 10.days.from_now)
    @group2 = create(:group, name: 'GroupSpec2', expiration_date: 10.days.ago)
    5.times { |i| instance_variable_set("@user#{i}", create(:user))}
    @group1.add_user @user1
    @group2.add_users [@user2, @user3]
    @guests_group = Refinery::Groups::Group.guest_group
  end
  
  {:refinery_superadmin => " Group Super Admin", :refinery_superuser => "SuperUser"}.each do |user, label|
    
    context "with #{label}" do
      
      refinery_login_with user
  
      describe "Create" do
    
        before do
          visit refinery.groups_admin_groups_path
          click_link I18n.t('refinery.groups.admin.groups.actions.create_new')
        end
    
        subject { page }
    
        context "with valid data" do
          it "should successfully create a new record" do
            fill_in "group_name", :with => "NewGroup1"
            expect {click_button('Save')}.to change(Refinery::Groups::Group, :count).by(1)
            current_path.should == refinery.groups_admin_groups_path
          end
        end
    
        context "with non valid data" do
          it "should fail on empty name" do
            expect {click_button('Save')}.to change(Refinery::Groups::Group, :count).by(0)
            label = "Name can't be blank"
            should have_content(label)
          end
      
          it "should fail on duplicates" do
            fill_in "group_name", :with => "GroupSpec1"
            expect {click_button('Save')}.to change(Refinery::Groups::Group, :count).by(0)
            label = 'Name has already been taken'
            should have_content(label)
          end
        end
      end
  
      describe "Edit" do
    
        context "with any group but guests" do
      
          before do
            visit refinery.edit_groups_admin_group_path(@group1)
          end
          subject { page }
    
          context "with valid data" do
            it "should successfully update the record" do
              fill_in "group_name", :with => "UpdatedGroup1"
              click_button('Save')
              should have_content("UpdatedGroup1")
              current_path.should == refinery.groups_admin_groups_path
            end
          end
    
          context "with non valid data" do
            it "should fail on duplicates" do
              fill_in "group_name", :with => "GroupSpec2"
              click_button('Save')
              label = 'Name has already been taken'
              should have_content(label)
            end
          end
      
        end
    
        context "with guests group" do
          it "should redirect to index" do
            visit refinery.edit_groups_admin_group_path(@guests_group)
            current_path.should == refinery.groups_admin_groups_path
          end
        end
    
      end
  
      describe "Destroy" do
        context "with any group but guests" do
          before do
            visit refinery.edit_groups_admin_group_path(@group1)
          end
          subject { page }
          it "should delete the group successfully" do
            expect {click_link I18n.t('refinery.groups.admin.groups.group.delete')}.to change(Refinery::Groups::Group, :count).by(-1)
          end
        end
      end
    end
  end
    
end


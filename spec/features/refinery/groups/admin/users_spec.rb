require 'spec_helper'

describe "Group Users management: " do
  
  before do
    @guests_group = create(:guest_group) rescue Refinery::Groups::Group.guest_group
    @group1 = create(:group, name: 'GroupSpec1', expires_on: 10.days.from_now)
    @group2 = create(:group, name: 'GroupSpec2', expires_on: 10.days.ago)
    5.times { |i| instance_variable_set("@user#{i}", create(:user))}
    @group1.add_users [@user1, logged_in_user]
    @group2.add_users [@user2, @user3]
  end
  
  #{:refinery_groupadmin => "GroupAdmin", :refinery_superadmin => "Group Super Admin", :refinery_superuser => "SuperUser"}.each do |user, label|
    
  {:refinery_superuser => "SuperUser"}.each do |user, label|
    
    context "with #{label}" do
      
      refinery_login_with user
      
      describe "Actions on existing users: " do
        
        it "index should redirect to group show page" do
          visit refinery.groups_admin_group_users_path(@group1)
          current_path.should == refinery.groups_admin_group_path(@group1)
        end
        
        context "any group but guest group" do
        
          before do
            visit refinery.groups_admin_group_path(@group1)
          end
      
          # it "should allow destroy any user but logged in user" do
#             label = I18n.t('refinery.admin.users.delete')
#             #binding.pry
#             within ("#sortable_#{@user1.id}") do
#               #binding.pry
#               expect {click_link label}.to change(Refinery::User, :count).by(-1)
#             end
#             link = refinery.groups_admin_group_user_path(@group1, logged_in_user)
#             should_not have_link(label, href: link)
#           end
          
        end
        
        context "Guest Group" do
          
          before do
            visit refinery.groups_admin_group_path(@group1)
          end
          
          it "should not allow destroying users" do
            label = I18n.t('refinery.admin.users.delete')
            [@user1, logged_in_user].each do |user|
              link = refinery.groups_admin_group_user_path(@group1, logged_in_user)
              should_not have_link(label, href: link)
            end
          end
        end
      
      end
      
    end
  
  end
      
end

# describe "group users management" do
#   #refinery_login_with :refinery_user
# 
#   before(:each) do
#     @group = create(:group, :name => "secondbureau")
#     @group2 = create(:group, :name => "2buro")
#     create(:group_admin)
#   end
# 
#   it "should have the link to add an new user in the users index page of group" do
#     visit refinery.groups_admin_group_users_path(@group)
#     page.should have_selector("a#add_user")
#     find("a#add_user").click
#     current_path.should == refinery.new_groups_admin_group_user_path(@group)
#   end
# 
#   it "should have the link to add an user on the group show page" do
#     visit refinery.groups_admin_group_path(@group)
#     page.should have_selector("a#add_user")
#     find("a#add_user").click
#     current_path.should == refinery.new_groups_admin_group_user_path(@group)
#   end
# 
#   it "should fail when some fileds are not filled" do
#     visit refinery.new_groups_admin_group_user_path(@group)
#     find(".wymupdate.button").click
#     page.should have_content("There were problems with the following fields:")
#   end
# 
#   it "should add a new user successfully" do
#     visit refinery.new_groups_admin_group_user_path(@group)
#     within("form.new_user") do
#       fill_in 'user_username', :with => 'markee'
#       fill_in 'user_email', :with => 'markee@mail.com'
#       fill_in 'user_password', :with => 'secret'
#       fill_in 'user_password_confirmation', :with => 'secret'
#     end
#     find(".wymupdate.button").click
#     current_path.should == refinery.groups_admin_group_path(@group)
#     @group.users.count.should == 1
#     # page.should have_content('markee')
#     pending "here I meet something wrong, I will fix it later"
#     pending "refinery ignore the uppercase 'Markee' will be 'markee',  pay attention here"
#   end
# 
#   describe "edit user and delete user" do
#     before(:each) do
#       @refinery_user = create(:refinery_user)
#       @group.add_user @refinery_user
#       @group.users.count.should == 1
#       visit refinery.groups_admin_group_path(@group)
#       page.should have_selector("a.delete_user")
#       page.should have_selector("a.edit_user")
#     end
# 
#     it "should edit user successfully" do
#       find("a.edit_user").click
#       current_path.should == refinery.edit_groups_admin_group_user_path(@group, @refinery_user)
# 
#       within("form.edit_user") do
#         fill_in 'user_username', :with => 'markee-edit'
#         fill_in 'user_email', :with => 'markee-edit@mail.com'
#         fill_in 'user_password', :with => 'secret-edit'
#         fill_in 'user_password_confirmation', :with => 'secret-edit'
#       end
#       find(".wymupdate.button").click
#       current_path.should == refinery.groups_admin_group_path(@group)
#       page.should have_content('markee-edit')
#     end
# 
#     it "should delete user successfully" do
#       find("a.delete_user").click
#       current_path.should == refinery.groups_admin_group_path(@group)
#       @group.users.count.should == 0
#     end
#   end
# 
# end
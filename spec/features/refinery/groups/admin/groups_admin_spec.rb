require 'spec_helper'

describe "Groups management :" do
  
  # {:refinery_superadmin => " Group Super Admin", :refinery_superuser => "SuperUser"}.each do |user, label|
#     
#     context "with #{label}" do
#   
#       refinery_login_with user
#   
#       before do
#          @group1 = create(:group, name: 'GroupAdminSpec1', expiration_date: 10.days.from_now)
#          @group2 = create(:group, name: 'GroupAdminSpec2', expiration_date: 10.days.ago)
#          @group3 = create(:group, name: 'GroupAdminSpec3')
#          5.times { |i| instance_variable_set("@user#{i}", create(:user))}
#          @group2.add_user @user1
#          @group3.add_users [@user2, @user3]
#          @guests_group = Refinery::Groups::Group.guest_group
#       end
# 
#       context "Index Page" do
#     
#         before { visit refinery.groups_admin_groups_path }
#         subject { page }
#     
#         it { should_not have_link(I18n.t('refinery.groups.admin.groups.group.delete'), href: refinery.groups_admin_group_path(@guests_group)) }
#         it { should_not have_link(I18n.t('refinery.groups.admin.groups.group.edit'), href: refinery.edit_groups_admin_group_path(@guests_group)) }
#         it { should have_link(I18n.t('refinery.groups.admin.groups.group.view_live_html'), href: refinery.groups_admin_group_path(@guests_group)) }
#     
#         it { should have_link(I18n.t('refinery.groups.admin.groups.group.delete'), href: refinery.groups_admin_group_path(@group1) ) }
#         it { should have_link(I18n.t('refinery.groups.admin.groups.group.edit'), href: refinery.edit_groups_admin_group_path(@group1)) }
#         it { should have_link(I18n.t('refinery.groups.admin.groups.group.view_live_html'), href: refinery.groups_admin_group_path(@group1)) }
#     
#         it { should have_link(I18n.t('refinery.groups.admin.groups.actions.create_new'), href: refinery.new_groups_admin_group_path) }
#         it { should have_selector("a#reorder_action") }
#     
#         # search ?
# 
#         #it { save_and_open_page }
# 
#       end
#   
#       context "Show Page" do
#     
#         context "with no user assigned" do
#     
#           before { visit refinery.groups_admin_group_path(@group1) }
#           subject { page }
#     
#           it { should have_content(@group1.name) }
#           it { should have_selector("p.description") }
#     
#           it "should show user count" do 
#             label = I18n.t('refinery.groups.admin.groups.show.users.zero') 
#             should have_content(label) 
#           end
#       
#           it { should_not have_selector(".users_selection")}
#       
#         end
#     
#     
#         context "with 1 user assigned" do
#     
#           before { visit refinery.groups_admin_group_path(@group2) }
#           subject { page }
#     
#           it { should have_content(@group2.name) }
#     
#           it "should show user count" do 
#             label = I18n.t('refinery.groups.admin.groups.show.users.one') 
#             should have_content(label) 
#           end
#       
#           it { should have_selector(".users_selection ul li")}
#           it { should have_content(@user1.username) } 
#           it { should have_content(@user1.email) } 
#           it { should have_selector("#sortable_#{@user1.id} span.groupadmin") } 
#           it { should have_content(Refinery::Groups.admin_role) }
# 
#         end
#     
#     
#         context "with 2 users assigned" do
#     
#           before { visit refinery.groups_admin_group_path(@group3) }
#           subject { page }
#     
#           it { should have_content(@group3.name) }
#     
#           it "should show user count" do 
#             label = I18n.t('refinery.groups.admin.groups.show.users.other', count: 2) 
#             should have_content(label) 
#           end
#       
#           it { should have_selector(".users_selection ul li")}
#           it { should have_content(@user2.username) } 
#           it { should have_content(@user2.email) } 
#           it { should have_selector("#sortable_#{@user2.id} span.groupadmin") } 
#           it { should have_content(@user3.username) } 
#           it { should have_content(@user3.email) } 
#           it { should_not have_selector("#sortable_#{@user3.id} span.groupadmin") } 
# 
#         end
#     
#         context "with nothing specific" do
#       
#           before do 
#             @group3.add_user create(:user)
#             visit refinery.groups_admin_group_path(@group3)
#           end
#       
#           subject { page }
#       
#           it "should delete the group successfully" do
#             expect {click_link I18n.t('refinery.groups.admin.groups.group.delete')}.to change(Refinery::Groups::Group, :count).by(-1)
#           end
#       
#         end
#     
#     
#         context "with 20 users assigned" do
#     
#           before do
#             @group4 = create(:group, name: 'GroupAdminSpec4')
#             20.times { @group4.add_user create(:user) }
#             visit refinery.groups_admin_group_path(@group4)
#           end
#           subject { page }
#     
#           it "should not have pagination" do 
#             should_not have_selector(".users_selection .pagination") 
#           end
# 
#         end
#     
#         context "with 21 users assigned" do
#     
#           before do
#             @group5 = create(:group, name: 'GroupAdminSpec5')
#             21.times { @group5.add_user create(:user) }
#             visit refinery.groups_admin_group_path(@group5)
#           end
#           subject { page }
#     
#           it "should have pagination" do 
#             should have_selector(".users_selection .pagination")  
#           end
#       
#         end
#     
#       end
#     
#     end
#     
#   end
  
  context "with GroupAdmin" do
    
    refinery_login_with :refinery_groupadmin
    
    before do
       @group1 = create(:group, name: 'GroupAdminSpec1', expiration_date: 10.days.from_now)
       5.times { |i| instance_variable_set("@user#{i}", create(:user))}
       @group1.add_users [@user1, @user2, @user3, logged_in_user]
       @guests_group = Refinery::Groups::Group.guest_group
    end
    
    context "Index Page" do
      before { visit refinery.groups_admin_groups_path }
      subject { page }
      it "should be redirected to its own group" do
        current_path.should == refinery.groups_admin_group_path(@group1)
      end
    end
    
  end
  
  context "with any user" do
    
    refinery_login_with :refinery_user
    
    before do
       @group1 = create(:group, name: 'GroupAdminSpec1', expiration_date: 10.days.from_now)
       5.times { |i| instance_variable_set("@user#{i}", create(:user))}
       @group1.add_users [@user1, @user2, @user3, logged_in_user]
       @guests_group = Refinery::Groups::Group.guest_group
    end
    
    context "Index Page" do
      before { visit refinery.groups_admin_groups_path }
      subject { page }
      it "should be redirected to home page" do
        current_path.should == refinery.root_path
      end
    end
    
  end

end

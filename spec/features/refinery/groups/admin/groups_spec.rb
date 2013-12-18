require 'spec_helper'

describe "Groups management :" do
  
  before do
     @guests_group = create(:guest_group) rescue Refinery::Groups::Group.guest_group
   end
  
  {:refinery_superadmin => " Group Super Admin", :refinery_superuser => "SuperUser"}.each do |user, label|
    
    context "with #{label}" do
  
      refinery_login_with user
  
      before do
         @group1 = create(:group, name: 'GroupAdminSpec1', expires_on: 10.days.from_now)
         @group2 = create(:group, name: 'GroupAdminSpec2', expires_on: 10.days.ago)
         @group3 = create(:group, name: 'GroupAdminSpec3')
         5.times { |i| instance_variable_set("@user#{i}", create(:user))}
         @group2.add_user @user1
         @group3.add_user @user2
         @group3.reload
         @group3.add_user @user3
      end

      context "Index Page" do
    
        before { visit refinery.groups_admin_groups_path }
        subject { page }
    
        it { should_not have_link(I18n.t('refinery.groups.admin.groups.group.delete'), href: refinery.groups_admin_group_path(@guests_group)) }
        it { should_not have_link(I18n.t('refinery.groups.admin.groups.group.edit'), href: refinery.edit_groups_admin_group_path(@guests_group)) }
        it { should have_link(I18n.t('refinery.groups.admin.groups.group.view'), href: refinery.groups_admin_group_path(@guests_group)) }
    
        it { should have_link(I18n.t('refinery.groups.admin.groups.group.delete'), href: refinery.groups_admin_group_path(@group1) ) }
        it { should have_link(I18n.t('refinery.groups.admin.groups.group.edit'), href: refinery.edit_groups_admin_group_path(@group1)) }
        it { should have_link(I18n.t('refinery.groups.admin.groups.group.view'), href: refinery.groups_admin_group_path(@group1)) }
    
        it { should have_link(I18n.t('refinery.groups.admin.groups.actions.create_new'), href: refinery.new_groups_admin_group_path) }
        it { should_not have_selector("a#reorder_action") }
    
        # search ?

        #it { save_and_open_page }

      end
  
      context "Show Page" do
    
        context "with no user assigned" do
    
          before { visit refinery.groups_admin_group_path(@group1) }
          subject { page }
    
          it { should have_content(@group1.name) }
          it { should have_selector("p.description") }
    
          it "should show user count" do 
            label = I18n.t('refinery.groups.admin.groups.show.users.zero') 
            should have_content(label) 
          end
      
          it { should_not have_selector(".users_selection")}
      
        end
    
    
        context "with 1 user assigned" do
    
          before { visit refinery.groups_admin_group_path(@group2) }
          subject { page }
    
          it { should have_content(@group2.name) }
    
          it "should show user count" do 
            label = I18n.t('refinery.groups.admin.groups.show.users.one') 
            should have_content(label) 
          end
      
          it { should have_selector(".pagination_container ul li")}
          it { should have_content(@user1.username) } 
          it { should have_content(@user1.email) } 
          it { should have_selector("#sortable_#{@user1.id} span.groupadmin") } 
          it { should have_content(I18n.t('refinery.groups.groupadmin')) }

        end
    
    
        context "with 2 users assigned" do
    
          before { visit refinery.groups_admin_group_path(@group3) }
          subject { page }
    
          it { should have_content(@group3.name) }
    
          it "should show user count" do 
            label = I18n.t('refinery.groups.admin.groups.show.users.other', count: 2) 
            should have_content(label) 
          end
      
          it { should have_selector(".pagination_container ul li")}
          it { should have_content(@user2.username) } 
          it { should have_content(@user2.email) } 
          it { should have_selector("#sortable_#{@user2.id} span.groupadmin") } 
          it { should have_content(@user3.username) } 
          it { should have_content(@user3.email) } 
          it { should_not have_selector("#sortable_#{@user3.id} span.groupadmin") } 

        end
    
        context "when navigating on any group but guests" do
      
          before do 
            @group3.add_user create(:user)
            visit refinery.groups_admin_group_path(@group3)
          end
      
          subject { page }
          
          it "should have new user link" do
            label = I18n.t('refinery.groups.admin.groups.group.add_user')
            link = refinery.new_groups_admin_group_user_path(@group3)
            should have_link(label, href: link)
          end
          it "should have delete link" do
            label = I18n.t('refinery.groups.admin.groups.group.delete')
            link = refinery.groups_admin_group_path(@group3)
            should have_link(label, href: link)
          end
          it "should have edit link" do
            label = I18n.t('refinery.groups.admin.groups.group.edit')
            link = refinery.edit_groups_admin_group_path(@group3)
            should have_link(label, href: link)
          end
      
        end
        
        context "when navigating on guests group" do
      
          before do 
            visit refinery.groups_admin_group_path(@guests_group)
          end
      
          subject { page }
          
          it "should have new user link" do
            label = I18n.t('refinery.groups.admin.groups.group.add_user')
            link = refinery.new_groups_admin_group_user_path(@guests_group)
            should have_link(label, href: link)
          end
          it "should not have delete link" do
            label = I18n.t('refinery.groups.admin.groups.group.delete')
            link = refinery.groups_admin_group_path(@guests_group)
            should_not have_link(label, href: link)
          end
          it "should not have edit link" do
            label = I18n.t('refinery.groups.admin.groups.group.edit')
            link = refinery.edit_groups_admin_group_path(@guests_group)
            should_not have_link(label, href: link)
          end
      
        end
    
    
        # context "with 20 users assigned" do
 #    
 #          before do
 #            @group4 = create(:group, name: 'GroupAdminSpec4')
 #            20.times { @group4.add_user create(:user) }
 #            visit refinery.groups_admin_group_path(@group4)
 #          end
 #          subject { page }
 #    
 #          it "should not have pagination" do 
 #            should_not have_selector(".users_selection .pagination") 
 #          end
 # 
 #        end
 #    
 #        context "with 21 users assigned" do
 #    
 #          before do
 #            @group5 = create(:group, name: 'GroupAdminSpec5')
 #            21.times { @group5.add_user create(:user) }
 #            visit refinery.groups_admin_group_path(@group5)
 #          end
 #          subject { page }
 #    
 #          it "should have pagination" do 
 #            should have_selector(".users_selection .pagination")  
 #          end
 #      
 #        end
    
      end
    
    end
    
  end
  
  context "with GroupAdmin" do
    
    refinery_login_with :refinery_groupadmin
    
    before do
       @group1 = create(:group, name: 'GroupAdminSpec1', expires_on: 15.days.from_now)
       @group2 = create(:group, name: 'GroupAdminSpec2', expires_on: 10.days.from_now)
       5.times { |i| instance_variable_set("@user#{i}", create(:user))}
       @group1.add_users [@user1, @user2, @user3, logged_in_user]
       @group2.add_user @user4
    end
    
    context "Index Page" do
      before { visit refinery.groups_admin_groups_path }
      subject { page }
      it "should be redirected to its own group" do
        current_path.should == refinery.groups_admin_group_path(@group1)
      end
    end
    
    describe "Create Page" do
      it "should redirect to its own group" do
        visit refinery.new_groups_admin_group_path
        current_path.should == refinery.groups_admin_group_path(@group1)
      end
    end
    
    describe "Edit Page" do
      it "should redirect to Show its own group" do
        visit refinery.edit_groups_admin_group_path(@group2)
        current_path.should == refinery.groups_admin_group_path(@group1)
        visit refinery.edit_groups_admin_group_path(@group1)
        current_path.should == refinery.groups_admin_group_path(@group1)
      end
    end
    
    context "Show Page" do
      
      context "when navigating on other group" do
        before { visit refinery.groups_admin_group_path(@group2) }
        subject { page }
        it "should be redirected to its own group" do
          current_path.should == refinery.groups_admin_group_path(@group1)
        end
      end
      
      context "when on its group" do
        before { visit refinery.groups_admin_group_path(@group1) }
        subject { page }
        it { should have_selector(".pagination_container ul li")}
        it "should display all usernames and emails" do
          [@user1, @user2, @user3, logged_in_user].each do |user|
            should have_content(user.username)
            should have_content(user.email)
          end
        end
        it "should have new user link" do
          label = I18n.t('refinery.groups.admin.groups.group.add_user')
          link = refinery.new_groups_admin_group_user_path(@group1)
          should have_link(label, href: link)
        end
        it "should not have delete link" do
          label = I18n.t('refinery.groups.admin.groups.group.delete')
          link = refinery.groups_admin_group_path(@group1)
          should_not have_link(label, href: link)
        end
        it "should not have edit link" do
          label = I18n.t('refinery.groups.admin.groups.group.edit')
          link = refinery.edit_groups_admin_group_path(@group1)
          should_not have_link(label, href: link)
        end
        
      end
    
    end  
    
  end
  
  # ERROR
#   
#   visit refinery.groups_admin_groups_path
#   ==> Capybara::InfiniteRedirectError: redirected more than 5 times, check for infinite redirects.
#   
#   context "with any logged user" do
#     
#     refinery_login_with :user
#     
#     before do
#        @group1 = create(:group, name: 'GroupAdminSpec1', expires_on: 10.days.from_now)
#        @group2 = create(:group, name: 'GroupAdminSpec2', expires_on: 10.days.from_now)
#        5.times { |i| instance_variable_set("@user#{i}", create(:user))}
#        @group1.add_user @user1
#        @group1.reload
#        @group1.add_users [@user2, @user3, logged_in_user]
#        @group2.add_user @user4
#     end
#     
#     context "Index Page" do
#       before {visit refinery.groups_admin_groups_path }
#       subject { page }
#       it "should be redirected to home page" do
#         binding.pry
#         current_path.should == refinery.root_path
#       end
#     end
#     
#     context "Show Page" do
#       it "should be redirected to home page" do
#         visit refinery.groups_admin_group_path(@group1)
#         current_path.should == refinery.root_path
#         visit refinery.groups_admin_group_path(@group2)
#         current_path.should == refinery.root_path
#       end
#     end
#     
#     context "Edit Page" do
#       it "should be redirected to home page" do
#         visit refinery.edit_groups_admin_group_path(@group1)
#         current_path.should == refinery.root_path
#         visit refinery.edit_groups_admin_group_path(@group2)
#         current_path.should == refinery.root_path
#       end
#     end
#     
#     context "New Page" do
#       before { visit refinery.new_groups_admin_group_path }
#       subject { page }
#       it "should be redirected to home page" do
#         current_path.should == refinery.root_path
#       end
#     end
#       
#   end
  
  context "with any anonymous user" do
  
  
      
    #refinery_login_with :user
    
    before do
       @group1 = create(:group, name: 'GroupAdminSpec1', expires_on: 10.days.from_now)
       5.times { |i| instance_variable_set("@user#{i}", create(:user))}
       @group1.add_users [@user1, @user2, @user3]
       #visit refinery.logout_path
    end
    
    context "Index Page" do
      before { visit refinery.groups_admin_groups_path }
      subject { page }
      it "should be redirected to login page" do
        #current_path.should == refinery.login_path
        current_path.should == refinery.signup_path
      end
    end
    
    context "Show Page" do
      it "should be redirected to login page" do
        visit refinery.groups_admin_group_path(@group1)
        #current_path.should == refinery.login_path
        current_path.should == refinery.signup_path
      end
    end
    
    context "Edit Page" do
      it "should be redirected to login page" do
        visit refinery.edit_groups_admin_group_path(@group1)
        #current_path.should == refinery.login_path
        current_path.should == refinery.signup_path
      end
    end
    
    context "New Page" do
      before { visit refinery.new_groups_admin_group_path }
      subject { page }
      it "should be redirected to login page" do
        #current_path.should == refinery.login_path
        current_path.should == refinery.signup_path
      end
    end
      
  end

end

require 'spec_helper'

module Refinery
  module Groups
    describe Group do
      
      before do
        @guests_group = create(:guest_group) rescue Refinery::Groups::Group.guest_group
      end
      
      it "should be creatable" do
        create(:group)
        expect { create(:group) }.to change(Refinery::Groups::Group, :count).by(1)
      end
      
      it "should be expired" do
        @group = create(:group, name: "GroupExpired", expires_on: Time.zone.today - 1.day)
        @group.soon_expired?.should be_false
        @group.expired?.should be_true
      end
      
      it "should be soon expired but not expired" do 
        @group = create(:group, name: "GroupSoonExpired", expires_on: Time.zone.today + Refinery::Groups.reminder - 2)
        @group.soon_expired?.should be_true
        @group.expired?.should be_false
      end
      
      it "should not be expired" do
        @group = create(:group, name: "GroupNotExpired", expires_on: Time.zone.today + Refinery::Groups.reminder + 2)
        @group.soon_expired?.should be_false
        @group.expired?.should be_false
      end
        

      context "when created with name 'GroupName'" do
        
        before (:each) do
          @group1 = create(:group, name: "GroupName")
        end
        
        it "should be valid" do
          @group1.should be_valid
        end
        
        it "should not raise any error" do
          @group1.errors.should be_empty
        end
        
        it "should have the name 'GroupName'" do
          @group1.name.should == "GroupName"
        end
        
        it "should not allow to create an other group with the same name" do
          group2 = build(:group, name: "GroupName")
          group2.should_not be_valid
        end
        
        it "should be destroyable" do
          expect { @group1.destroy }.to change(Refinery::Groups::Group, :count).by(-1)
        end
        
      end
      
      context "if is 'Guests' group " do
        
        before (:each) do 
          @group1 = Refinery::Groups::Group.guest_group
        end
        
        it "should not be destroyable" do
          expect { @group1.destroy }.to change(Refinery::Groups::Group, :count).by(0)
        end
      
      end
          
      

      context "when managing users" do
        
        before(:each) do
          #Refinery::User.delete_all
          #Refinery::Groups::Group.delete_all
          @group = create(:group, name: "GroupSpec1")
          @user1 = create(:user)
          @user2 = create(:user)
          @group_admin_role = Refinery::Role[Refinery::Groups.admin_role]
        end

        it "should add them successfully" do
          @group.users.size.should == 0
          @group.add_user @user1
          @group.add_user @user2
          @group.reload
          @group.users.size.should == 2
        end

        it "should not add duplicate user" do
          @group.users.size.should == 0
          @group.add_user @user1
          @group.add_user @user1
          @group.reload
          @group.users.size.should == 1
        end

        it "should assign only the first user's role to GroupAdmin" do
          @group.users.size.should == 0
          @group.add_user @user1
          @group.reload
          @group.add_user @user2
          @user1.roles.should include(@group_admin_role)
          @user2.roles.should_not include(@group_admin_role)
        end

        it "should remove a user successfully" do
          @group.users.size.should == 0
          @group.add_user @user1
          @group.reload
          @group.users.size.should == 1
          @group.remove_user @user1
          @group.reload
          @group.users.size.should == 0
          
        end

        it "should remove the GroupAdmin role after the user is removed from a group" do
          @group.users.size.should == 0
          @group.add_user @user1
          @user1.roles.should include(@group_admin_role)
          @group.remove_user @user1
          @group.reload
          @group.users.size.should == 0
          @user1.roles.should_not include(@group_admin_role)
        end

        it "should assign all its users to Guest group after being destroyed" do
          @group.users.size.should == 0
          @group.add_user @user1
          @group.add_user @user2
          @group.reload
          @group.users.size.should == 2
          @group.destroy
          @user1.reload
          @user2.reload
          @user1.group_id.should == @guests_group.id
          @user2.group_id.should == @guests_group.id
        end

      end


    end
  end
end

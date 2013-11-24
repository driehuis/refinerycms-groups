require 'spec_helper'

module Refinery
  module Groups
    describe Group do
      
      it "should be creatable" do
        create(:group)
        expect { create(:group) }.to change(Refinery::Groups::Group, :count).by(1)
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
          @group.users.count.should == 0
          @group.add_user @user1
          @group.add_user @user2
          @group.users.count.should == 2
        end

        it "should not add duplicate user" do
          @group.users.count.should == 0
          @group.add_user @user1
          @group.add_user @user1
          @group.users.count.should == 1
        end

        it "should assign only the first user's role to GroupAdmin" do
          @group.users.count.should == 0
          @group.add_user @user1
          @group.add_user @user2
          @user1.roles.should include(@group_admin_role)
          @user2.roles.should_not include(@group_admin_role)
        end

        it "should remove a user successfully" do
          @group.users.count.should == 0
          @group.add_user @user1
          @group.users.count.should == 1
          @group.remove_user @user1
          @group.users.count.should == 0
          
        end

        it "should remove the GroupAdmin role after the user is removed from a group" do
          @group.users.count.should == 0
          @group.add_user @user1
          @user1.roles.should include(@group_admin_role)
          @group.remove_user @user1
          @group.users.count.should == 0
          @user1.roles.should_not include(@group_admin_role)
        end

        it "should assign all its users to Guest group after being destroyed" do
          @group.users.count.should == 0
          @group.add_user @user1
          @group.add_user @user2
          @group.users.count.should == 2
          uid1 = @user1.id
          uid2 = @user2.id
          @group.destroy
          Refinery::User.where(id: uid1).first.group_id.should == Refinery::Groups::Group.guest_group.id
          Refinery::User.where(id: uid2).first.group_id.should == Refinery::Groups::Group.guest_group.id
        end

      end


    end
  end
end

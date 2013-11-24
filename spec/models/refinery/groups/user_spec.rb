require 'spec_helper'

describe "Users when created" do  
  it "should belongs to 'Guests' group" do
    user = create(:user)
    user.group_name.should == Refinery::Groups::Group.guest_group.name
  end
end

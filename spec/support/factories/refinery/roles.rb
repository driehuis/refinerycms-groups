
FactoryGirl.define do
  factory :role, :class => Refinery::Role do
    sequence(:title) { |n| "refinery#{n}" }
  end

  factory :group_admin, :class => Refinery::Role do
    title Refinery::Groups.admin_role
  end
  
  factory :group_superadmin, :class => Refinery::Role do
    title Refinery::Groups.superadmin_role
  end
  
end
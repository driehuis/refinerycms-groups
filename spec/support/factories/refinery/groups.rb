require_relative '../../lipsum'

FactoryGirl.define do
  factory :group, :class => Refinery::Groups::Group do
    sequence(:name) { |n| "refinery#{n}" }
    #expires_on Time.now
    description Lipsum.generate :words => 50
  end

  factory :guest_group, :class => Refinery::Groups::Group do
    name Refinery::Groups.guest_group
  end

end


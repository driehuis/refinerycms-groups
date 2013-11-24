# This is a temporary hack to get around some hackery with Devise when
# using the authentication macros in request specs that are defined in
# refinerycms-testing. If you remove this line ensure that tests pass
# in an extension that is testing against this Factory via the
# authentication macros in refinerycms-testing.
# 10-11-2011 - Jamie Winsor - jamie@enmasse.com
require Refinery.roots(:'refinery/authentication').join("app/models/refinery/role.rb")

FactoryGirl.define do
  factory :user, :class => Refinery::User do
    sequence(:username) { |n| "User#{n}" }
    sequence(:email) { |n| "user#{n}@example.org" }
    password  "refinerycms"
    password_confirmation "refinerycms"
  end

  factory :refinery_user, :parent => :user do
    roles { [ ::Refinery::Role[:refinery] ] }

    after(:create) do |user|
      ::Refinery::Plugins.registered.each_with_index do |plugin, index|
        user.plugins.create(:name => plugin.name, :position => index)
      end
    end
  end

  factory :refinery_superuser, :parent => :refinery_user do
    roles { [ ::Refinery::Role[:refinery], ::Refinery::Role[:superuser] ]}
  end
  
  factory :refinery_superadmin, :parent => :refinery_user do
    roles { [ ::Refinery::Role[:refinery], ::Refinery::Role[Refinery::Groups.superadmin_role] ]}
    after(:create) do |user|
      user.plugins.create(:name => 'refinery_groups', :position => 0)
    end
  end
  
  factory :refinery_groupadmin, :parent => :refinery_user do
    roles { [ ::Refinery::Role[:refinery], ::Refinery::Role[Refinery::Groups.admin_role] ]}
    after(:create) do |user|
      user.plugins.create(:name => 'refinery_groups', :position => 0)
    end
  end

  factory :refinery_translator, :parent => :user do
    roles { [ ::Refinery::Role[:refinery], ::Refinery::Role[:translator] ] }

    after(:create) do |user|
      user.plugins.create(:name => 'refinery_pages', :position => 0)
    end
  end
end
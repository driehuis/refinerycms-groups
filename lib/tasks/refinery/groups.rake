require_relative '../../lipsum'

namespace :refinery do

  namespace :groups do

    # call this task by running: rake refinery:groups:my_task
    # desc "Description of my task below"
    # task :my_task => :environment do
    #   # add your logic here
    # end
    
    task :populate => :environment do 
      Refinery::User.where('username like ? or username like ?', 'User%', 'Guest%').each {|_| _.destroy}
      Refinery::Groups::Group.where('name like ?', 'Group%').each {|_| _.destroy}
      30.times do |i| 
        @group = Refinery::Groups::Group.create(
          name: "Group_#{i}", 
          expires_on: Time.now + 100.days, 
          description: Lipsum.generate(words: 50, start_with_lipsum: false)
        )
        rand(5).times do |j|
          Refinery::User.create(
            username: "User_#{i}#{j}",
            email: "user#{i}#{j}@example.org",
            password: "secret",
            password_confirmation: "secret",
            group_id: @group.id
          )
        end
      end
      
      5.times do |j|
        Refinery::User.create(
          username: "Guest_#{j}",
          email: "guest#{j}@example.org",
          password: "secret",
          password_confirmation: "secret",
          group_id: Refinery::Groups::Group.guest_group.id
        )
      end
      
      #@group1 = create(:group, name: 'GroupAdminSpec1', expires_on: 15.days.from_now)
      #@group2 = create(:group, name: 'GroupAdminSpec2', expires_on: 10.days.from_now)
      #5.times { |i| instance_variable_set("@user#{i}", create(:user))}
      
    end

  end

end
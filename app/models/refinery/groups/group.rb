module Refinery
  module Groups
    class Group < Refinery::Core::BaseModel
      
      self.table_name = 'refinery_groups'

      attr_accessible :name, :position, :description, :expires_on

      validates :name, :presence => true, :uniqueness => true

      has_many :users, :class_name => "Refinery::User"

      acts_as_indexed :fields => [:name]

      default_scope order("name")

      before_destroy :assign_users_to_guest_group
      
      
      def self.guest_group
        @@guest_group ||=  Refinery::Groups::Group.find_or_create_by_name(Refinery::Groups.guest_group)
      end
      
      
      
      def has_user?(user)
        users.include? user
      end
      
      def expired?
        expires_on > Time.zone.today
      end
      
      def soon_expired?
        expires_on > Time.zone.today - Refinery::Groups.reminder.to_i
      end
     
      def is_guest_group?
        name.eql?(Refinery::Groups.guest_group)
      end


      def admin
        users.each do |user|
          return user if user.has_role?(Refinery::Groups.admin_role)
        end
        nil
      end


      def add_user user
        user.add_role(Refinery::Groups.admin_role) if users.count.eql?(0)
        user.group = self
        user.save
      end

      def add_users many_users
        many_users.each do |user|
          add_user user
        end
      end

      def remove_user user
        self.class.guest_group.add_user user
        user.roles.delete Refinery::Role.find_by_title(Refinery::Groups.admin_role) if user.has_role?(Refinery::Groups.admin_role)
      end
      
      
      def assign_users_to_guest_group
        return false unless destroyable?
        users.each do |user|
          user.roles.delete Refinery::Role.find_by_title(Refinery::Groups.admin_role) if user.has_role?(Refinery::Groups.admin_role)
        end
        self.class.guest_group.add_users users
      end
      
      def destroyable?
        !name.eql?(Refinery::Groups.guest_group)
      end
      
    end
  end
end

module Refinery
  module Groups
    class Group < Refinery::Core::BaseModel
      
      self.table_name = 'refinery_groups'

      #attr_accessible :name, :position, :description, :expires_on, :user_ids
      

      validates :name, :presence => true, :uniqueness => true
      validates :expires_on, :presence => true

      has_many :users, :class_name => "Refinery::User"

      acts_as_indexed :fields => [:name]

      default_scope { order(:name) }

      before_destroy :destroyable?
      before_destroy :assign_users_to_guest_group
      
      scope :active, where('expires_on is not null and expires_on >= ?', Time.zone.today)
      scope :expired, where('expires_on is null or expires_on < ?', Time.zone.today)
      scope :soon_expired, where('expires_on is not null and expires_on >= ? and expires_on <= ?', Time.zone.today, Time.zone.today + Refinery::Groups.reminder.to_i)
      
      
      def self.guest_group
        Refinery::Groups::Group.find_by_name(Refinery::Groups.guest_group)
      end
      
      def has_user?(user)
        users.include? user
      end
      
      def active?
         !expires_on.nil? && expires_on >= Time.zone.today
      end
      
      def expired?
        expires_on.nil? || expires_on < Time.zone.today
      end
      
      def soon_expired?
        !expires_on.nil? && expires_on.between?(Time.zone.today, Time.zone.today + Refinery::Groups.reminder.to_i)
      end
      
      def status
        return :expired if expired?
        return :soon_expired if soon_expired?
        return :active if active?
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
        users.each  {|u| remove_user u }
        true
      end
      
      def destroyable?
        !name.eql?(Refinery::Groups.guest_group)
      end
      
    end
  end
end

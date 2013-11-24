Refinery::User.class_eval do
  
  belongs_to :group, :class_name => "Refinery::Groups::Group"
  delegate :name, :to => :group, :prefix => true, :allow_nil => true
  
  before_create :assign_to_guest_group, unless:  Proc.new { |u| u.attribute_present?(:group_id) }
  
  def is_group_admin?
    has_role?(Refinery::Groups.admin_role) && !has_role?(:superuser) && !has_role?(Refinery::Groups.superadmin_role)
  end
  
  def is_group_superadmin?
    has_role?(Refinery::Groups.superadmin_role) || has_role?(:superuser)
  end
  
  def can_admin_group?(group)
    return false if group.nil?
    has_role?(Refinery::Groups.admin_role) && group.users.include?(self) || has_role?(Refinery::Groups.superadmin_role) || has_role?(:superuser) 
  end
  
  private
  
  def assign_to_guest_group
    self.group = Refinery::Groups::Group.guest_group
  end
  
end
Refinery::User.class_eval do
  
  belongs_to :group, :class_name => "Refinery::Groups::Group", counter_cache: true
  delegate :name, :to => :group, :prefix => true, :allow_nil => true
  
  attr_accessible :group_id, :has_admin_role 
  
  before_save :assign_to_guest_group, unless:  Proc.new { |u| u.attribute_present?(:group_id) }
  before_save :assign_group_admin_role, unless:  Proc.new { |u| u.has_admin_role? }
  
  def is_group_admin?
    has_role?(Refinery::Groups.admin_role) && !has_role?(:superuser) && !has_role?(Refinery::Groups.superadmin_role)
  end
  
  def is_group_superadmin?
    has_role?(Refinery::Groups.superadmin_role) || has_role?(:superuser)
  end
  
  def can_admin_group?(group)
    return false if group.nil?
    has_role?(Refinery::Groups.admin_role) && group.users.include?(self) || is_group_superadmin? 
  end
  
  def add_admin_role
    self.add_role Refinery::Groups.admin_role
    @has_admin_role = true
  end
  
  def has_admin_role?
    @has_admin_role
  end
  
  private
  
  def assign_to_guest_group
    self.group = Refinery::Groups::Group.guest_group
  end
  
  def assign_group_admin_role
    return if group.is_guest_group?
    add_admin_role if group.users.size.eql?(0) || !group.admin
  end
  
end
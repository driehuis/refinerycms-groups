module Refinery
  module Groups
    include ActiveSupport::Configurable

    config_accessor :guest_group, :admin_role, :superadmin_role

    self.guest_group  = "Guests"
    self.admin_role    = "Groupadmine"
    self.superadmin_role   = "Bureau"
        
  end
end

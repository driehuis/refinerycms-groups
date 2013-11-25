module Refinery
  module Groups
    include ActiveSupport::Configurable

    config_accessor :guest_group, :admin_role, :superadmin_role, :reminder

    self.guest_group      = "Guests"
    self.admin_role       = "Groupadmin"
    self.superadmin_role  = "Bureau"
    self.reminder         = 60
        
  end
end

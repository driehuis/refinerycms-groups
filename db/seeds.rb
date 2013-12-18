Refinery::I18n.frontend_locales.each do |lang|
  I18n.locale = lang
  
  if defined?(Refinery::User)
    Refinery::User.all.each do |user|
      if user.plugins.where(:name => 'refinerycms-groups').blank?
        user.plugins.create(:name => 'refinerycms-groups',
                            :position => (user.plugins.maximum(:position) || -1) +1)
      end
    end
  end

  url = "/groups"
  if defined?(Refinery::Page) && Refinery::Page.where(:link_url => url).empty?
    page = Refinery::Page.create(
      :title => 'Groups',
      :link_url => url,
      :deletable => false,
      :menu_match => "^#{url}(\/|\/.+?|)$"
    )
    Refinery::Pages.default_parts.each_with_index do |default_page_part, index|
      page.parts.create(:title => default_page_part, :body => nil, :position => index)
    end
  end
end

# create Guest Group
Refinery::Groups::Group.create(name: Refinery::Groups.guest_group, description: 'Guests Group', expires_on: Date.new(2099,12,31))

# create roles
Refinery::Role[Refinery::Groups.admin_role]
Refinery::Role[Refinery::Groups.superadmin_role]


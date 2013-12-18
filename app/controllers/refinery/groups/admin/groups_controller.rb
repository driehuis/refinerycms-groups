module Refinery
  module Groups
    module Admin
      class GroupsController < ::Refinery::AdminController

        crudify :'refinery/groups/group', :title_attribute => 'name', :xhr_paging => true, :sortable => false
        
        before_filter :find_group,                  :except => [:index, :new, :create]
        before_filter :find_users,                  :only => [:show, :edit, :update]
        before_filter :redirect_if_not_admin,       :only => :index
        before_filter :redirect_if_cannot_show,     :only => [:show, :edit, :destroy]
        before_filter :redirect_if_cannot_destroy,  :only => :destroy
        before_filter :redirect_if_cannot_edit,     :only => :edit
        before_filter :redirect_if_cannot_create,   :only => [:new, :create]

        def index
          @groups = Refinery::Groups::Group
          @groups = @groups.where("lower(name) like ?", "%#{params[:search].downcase}%") if params[:search]
          @groups = @groups.active if params[:status].eql?('active')
          @groups = @groups.soon_expired if params[:status].eql?('soon_expired')
          @groups = @groups.expired if params[:status].eql?('expired')
          @groups = @groups.paginate(:page => params[:page])
          @filtered = params[:status] unless params[:status].eql?('all')
        end


      private
        
        def find_group
          @group = Refinery::Groups::Group.find(params[:id])
          if @group.nil?
            flash[:error] = t("refinery.groups.admin.groups.records.sorry_no_results")
            redirect_to refinery.groups_admin_groups_path and return
          end
          if current_refinery_user.is_group_admin? && @group != current_refinery_user.group
            redirect_to refinery.groups_admin_group_path(current_refinery_user.group) and return
          end
        end
        
        def find_users
          unless @group.nil?
            @users = @group.users.order(:username).paginate(:page => params[:page])
          end
        end
        

        def redirect_if_cannot_show
          redirect_to refinery.groups_admin_groups_path, :flash => {:error => t("refinery.groups.admin.errors.cannot_find")} unless current_refinery_user.can_admin_group?(@group) 
        end


        def redirect_if_cannot_create
          redirect_to refinery.groups_admin_groups_path, :flash => {:error => t("refinery.groups.admin.errors.cannot_create")} unless current_refinery_user.is_group_superadmin?
        end
        
        
        def redirect_if_cannot_edit
          redirect_to refinery.groups_admin_groups_path, :flash => { :error => t("refinery.groups.admin.errors.cannot_edit")} unless current_refinery_user.is_group_superadmin? && !@group.is_guest_group?
        end
        
        
        def redirect_if_cannot_destroy
          redirect_to refinery.groups_admin_groups_path, :flash => { :error => t("refinery.groups.admin.errors.cannot_destroy") } unless current_refinery_user.is_group_superadmin? && !@group.is_guest_group?
        end

        def redirect_if_not_admin
          unless current_refinery_user.is_group_superadmin?
            redirect_to refinery.groups_admin_group_path(current_refinery_user.group) and return if current_refinery_user.is_group_admin?
            redirect_to refinery.root_path, :flash => { :error => t("refinery.groups.admin.errors.cannot_show") } 
          end
        end
       
      end
    end
  end
end

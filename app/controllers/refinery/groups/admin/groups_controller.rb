module Refinery
  module Groups
    module Admin
      class GroupsController < ::Refinery::AdminController

        crudify :'refinery/groups/group', :title_attribute => 'name', :xhr_paging => true
        
        before_filter :find_current_group,          :only => [:show, :edit]
        before_filter :find_group,                  :only => [:add_users, :set_admin, :destroy]
        before_filter :redirect_if_not_admin,       :only => :index
        before_filter :redirect_if_cannot_show,     :only => [:show, :edit, :destroy]
        before_filter :redirect_if_cannot_destroy,  :only => :destroy
        before_filter :redirect_if_cannot_edit,     :only => :edit
        before_filter :redirect_if_cannot_reate,    :only => :new

        def index
          if params[:search]
            @groups = Refinery::Groups::Group.where("lower(name) like ?", "%#{params[:search].downcase}%").paginate(:page => params[:page])
          else
            @groups = Refinery::Groups::Group.paginate(:page => params[:page])
          end
        end


        def find_all_groups(search = nil)
          if current_refinery_user.is_group_superadmin?
            @groups = Refinery::Groups::Group.paginate(:page => params[:page])
          elsif current_refinery_user.has_role?(Refinery::Groups.admin_role)
            @groups = Refinery::Groups::Group.where(:name => current_refinery_user.group.name).paginate(:page => params[:page])
          end
        end


        def show
          @users = @group.users.order(:email).paginate(:page => params[:page])
        end

        
        def edit
          @users = @group.users.paginate(:page => params[:page])
        end


        def add_users
          user_ids = params[:user_ids].split(",")
          @users = Refinery::User.where(:id => user_ids)
          @group.add_users @users
          @group.save
          redirect_to refinery.groups_admin_group_path(@group)
        end


        def set_admin
          @user = Refinery::User.find(params[:user_id])
          unless @user.nil?
            @user.roles << Refinery::Role.find_by_title(Refinery::Groups.admin_role)
            @user.save
          end
          redirect_to refinery.groups_admin_group_path(@group)
        end


      private

        
        def find_group
          @group = Refinery::Groups::Group.find(params[:id])
          if @group.nil?
            flash[:error] = t("refinery.groups.admin.groups.records.sorry_no_results")
            redirect_to refinery.groups_admin_groups_path and return
          end
        end


        def find_current_group
          if current_refinery_user.is_group_admin?
            @group = current_refinery_user.group
          else
            find_group
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

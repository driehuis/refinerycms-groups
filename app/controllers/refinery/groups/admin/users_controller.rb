module Refinery
  module Groups
    module Admin
      class UsersController < ::Refinery::AdminController
        crudify :'refinery/user',
              :order => 'username ASC',
              :title_attribute => 'username',
              :xhr_paging => true

        before_filter :find_group
        before_filter :find_all_guest_users, :only => :new
        before_filter :has_admin, :only => [:new, :edit]

        def index
          @users = Refinery::Groups::Group.find(params[:group_id]).users.paginate(:page => params[:page])
        end

        def new
          @user = Refinery::User.new
        end

        def edit
          redirect_unless_user_editable!
        end

        def create
    
          if params[:cancel]
            redirect_to refinery.groups_admin_group_path(current_refinery_user.group), :notice => t('canceled') and return 
          end
    
          @user = Refinery::User.new params[:user]
          if @user.group && @user.group.name != "guest"
            @user.roles << Refinery::Role.find_by_title("Member")
          end
          if params[:admin]
            @user.roles << Refinery::Role.find_by_title("GroupAdmin")
          end

          if @user.save
            redirect_to refinery.groups_admin_group_path(@user.group),
              :notice => t('created', :what => @user.username, :scope => 'refinery.crudify')
          else
            @group = Refinery::Groups::Group.find(params[:user][:group_id])
            find_all_guest_users
            render :action => 'new'
          end
        end

        def update
    
          if params[:cancel]
            redirect_to refinery.groups_admin_group_path(current_refinery_user.group), :notice => t('canceled') and return 
          end
    
          redirect_unless_user_editable!
          @user = find_user
    
           unless @group.name.eql?("guest") || (current_refinery_user.eql?(@user) && current_refinery_user.has_role?('GroupAdmin'))
       
            if params[:admin]
              @user.roles << Refinery::Role.find_by_title("GroupAdmin")
            else
              @user.roles.delete Refinery::Role.find_by_title("GroupAdmin")
            end
      
          end

          # Prevent the current user from locking themselves out of the User manager or backend
          if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
            params[:user].except!(:password, :password_confirmation)
          end

          if @user.update_attributes params[:user]
            redirect_to refinery.groups_admin_group_path(@group), :notice => t('updated', :what => @user.username, :scope => 'refinery.crudify') and return
          else
            @user.save
            render :edit
          end
        end
        
        def destroy
          user = find_user
          if user.username.eql?(current_refinery_user.username)
            flash[:notice] = t("refinery.groups.cant_delete_self")
            redirect_to refinery.groups_admin_group_path(@group) and return
          end
    
          if user.group.name.eql?("guest") || current_refinery_user.has_role?('GroupAdmin')
            flash[:notice] = t("refinery.groups.user_deleted_successfully")
            user.destroy
          else
            flash[:notice] = t("refinery.groups.user_deleted_from_group_successfully")
            guest_group = Refinery::Groups::Group.guest_group
            user.group = guest_group
            user.save
          end
    
          redirect_to refinery.groups_admin_group_path(@group)
        end
        
        protected

         def find_user_with_slug
           begin
             find_user_without_slug
           rescue ActiveRecord::RecordNotFound
             @user = Refinery::User.all.detect{|u| u.to_param == params[:id]}
           end
         end
         alias_method_chain :find_user, :slug

      private
      
      

        def has_admin
          @has_admin = Refinery::Groups::Group.find(params[:group_id]).admin
        end

        def find_group
          if request["action"] == "create"
            @group = Refinery::Groups::Group.find(params[:user][:group_id])
          else
            @group = Refinery::Groups::Group.find(params[:group_id])
          end
        end

        def find_all_guest_users
          group_id = Refinery::Groups::Group.find_by_name("guest")
          @users = Refinery::User.where(:group_id => group_id).order("email").paginate(:page => params[:page])
        end

        def redirect_unless_user_editable!
          user = find_user
          unless current_refinery_user.can_edit?(user) ||
            (current_refinery_user.has_role?("GroupAdmin") && user.group && user.group == current_refinery_user.group)
            redirect_to refinery.admin_users_path and return
          end
        end

      end
    end
  end
end

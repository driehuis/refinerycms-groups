module Refinery
  module Groups
    module Admin
      class UsersController < ::Refinery::AdminController
        
        crudify :'refinery/user', :order => 'username ASC', :title_attribute => 'username', :xhr_paging => true

        before_filter :find_group
        before_filter :find_user,                               only: [:edit, :destroy, :update]
        before_filter :redirect_to_group_show,                  only: [:index, :show]
        before_filter :redirect_if_cannot_destroy,              only: [:destroy]
        before_filter :redirect_unless_user_editable!,          only: [:edit, :update]
        before_filter :redirect_if_cannot_edit,                 only: [:edit, :update]
        before_filter :exclude_password_assignment_when_blank!, only: [:update]
        before_filter :find_guests,                             only: [:new, :create]
        after_filter  :assign_group_admin_if_none,              only: [:update, :destroy]
                
        def new
          @user = Refinery::User.new
        end
        
        def create
          redirect_to refinery.groups_admin_group_path(@group), :notice => t('canceled') and return if params[:cancel]
          @user = Refinery::User.new params[:user]
          @user.add_role Refinery::Groups.admin_role if params[:admin]
          if @user.save
            create_successful
          else
            create_failed
          end
        end
        
        def update
          redirect_to refinery.groups_admin_group_path(@group), :notice => t('canceled') and return if params[:cancel]    
          if current_refinery_user.eql?(@user) && current_refinery_user.has_role?(Refinery::Groups.admin_role) 
            flash.now[:notice] = t('lockout_prevented', :scope => 'refinery.admin.users.update') if !params[:admin]
          else
            if params[:admin]
              @user.add_role Refinery::Groups.admin_role
            else
              #@user.roles.delete Refinery::Groups.admin_role
              @user.roles.delete Refinery::Role.where(title: Refinery::Groups.admin_role).first
            end
          end
          
          if @user.update_attributes params[:user]
            update_successful
          else
            update_failed
          end
        end
        
        def destroy
          if @user.eql?(current_refinery_user)
            flash[:notice] = t("refinery.groups.admin.users.errors.cannot_destroy_self")
            redirect_to refinery.groups_admin_group_path(@group) and return
          end
          if @group.eql?(Refinery::Groups::Group.guest_group) || @group.eql?(current_refinery_user.group)
            if @user.destroy
              flash[:notice] = t("refinery.groups.admin.users.actions.successfully_destroyed")
            else
              flash[:warning] = t("refinery.groups.admin.errors.unexpected")  
            end
          else
            @group.remove_user @user
            if @user.save
                flash[:notice] = t("refinery.groups.admin.users.actions.successfully_transfered")
            else
                flash[:warning] = t("refinery.groups.admin.errors.unexpected")  
            end
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
      
        def find_group
          @group = Refinery::Groups::Group.find(params[:group_id])
        end
      
        def find_guests
          @users = Refinery::Groups::Group.guest_group.users
          #binding.pry
        end
      
        def redirect_to_group_show(flash=nil)
          flash[:error] = flash unless flash.nil?
          redirect_to refinery.groups_admin_group_path(@group)
        end
      
        def redirect_if_cannot_destroy
          redirect_to_group_show t("refinery.groups.admin.users.errors.cannot_destroy") unless current_refinery_user.can_admin_group?(@group)
        end
      
        def redirect_if_cannot_edit
          redirect_to_group_show t("refinery.groups.admin.users.errors.cannot_destroy") unless current_refinery_user.can_edit?(@user) || current_refinery_user.can_admin_group?(@group)
        end
      
        def redirect_unless_user_editable!
          redirect_to_group_show unless current_refinery_user.can_edit?(@user)
        end
      
        def create_successful
          redirect_to refinery.groups_admin_group_path(@group), :notice => t('created', :what => @user.username, :scope => 'refinery.crudify')
        end
      
        def create_failed
          render :action => 'new'
        end
      
        def update_successful
          redirect_to refinery.groups_admin_group_path(@group), :notice => t('updated', :what => @user.username, :scope => 'refinery.crudify')
        end
      
        def update_failed
          render :edit
        end
      
        def exclude_password_assignment_when_blank!
          params[:user].except!(:password, :password_confirmation) if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        end
        
        def assign_group_admin_if_none
          unless @group.is_guest_group? || @group.admin
            unless (user = @group.users.first).nil?
              user.add_admin_role
              user.save
            end
          end
        end
        
      end
    end
  end
end

Refinery::Core::Engine.routes.append do

  # Admin routes
  namespace :groups, :path => '' do
    namespace :admin, :path => 'refinery' do
      resources :groups do
        member do
          post :add_users
          get :set_admin
        end
        collection do
          get :update_positions
        end
        resources :users
      end
    end
  end

end

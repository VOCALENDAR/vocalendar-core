VocalendarCore::Application.routes.draw do
  match 'l/:short_id', :controller => :ex_links, :action => :redirect, :as => 'link_redirect', :format => false

  mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get   'sign_in',  :to => 'devise/sessions#new',     :as => :new_user_session
    match 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  namespace 'external_ui', :path => 'ex' do
    scope 'events' do
      get 'gid/:gid' => 'events#show', :as => 'event_by_gid'
      get 'eid/:eid' => 'events#show', :as => 'event_by_eid'
      get 'uid/:uid' => 'events#show', :as => 'event_by_uid'
    end
    resources :events, :only => [:index, :show]
    resources :release_events, :only => [:index, :show]
  end

  resources :events do
    resources :histories, :only => :index
  end
  resources :release_events, :path => 'release' do
    resources :histories, :only => :index
  end
  resources :calendars do
    resources :histories, :only => :index
  end
  resources :users do
    resources :histories, :only => :index
  end
  resources :tags do
    resources :events
    resources :histories, :only => :index
  end

  scope 'manage' do
    resources :ex_links
    resources :settings, :only => [:index, :destroy]
    put 'settings/set' => 'settings#set', :as => :set_setting
    resources :histories, :only => :index
  end

  match 'dashboard(/:action)', :controller => 'dashboard', :as => 'dashboard'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'dashboard#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

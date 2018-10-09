Rails.application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  use_doorkeeper
  get 'l/:short_id', to: 'ex_links#redirect', as: 'link_redirect', format: false

  mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  namespace 'external_ui', path: 'ex' do
    %w(gid eid uid).each do |xid|
      get "events/#{xid}/:#{xid}", to: 'events#show', as: "event_by_#{xid}"
    end
    get 'cd-releases', to: 'events#cd_releases'
    get 'cd-releases-body', to: 'events#cd_releases_body'
    resources :events, only: [:index, :show]
    resources :release_events, only: [:index, :show]
  end

  resources :events do
    resources :histories, only: :index
  end
  resources :release_events, path: 'release' do
    resources :histories, only: :index
  end
  resources :calendars do
    resources :histories, only: :index
  end
  resources :users do
    resources :histories, only: :index
  end
  resources :tags do
    resources :events
    resources :histories, only: :index
  end

  resources :events do
    resource :favorite, only: [:show, :create, :destroy]
  end

  scope 'manage' do
    resources :ex_links do
      member do
        put 'update_by_uri', to: 'ex_links#update_by_uri'
      end
    end
    resources :settings, only: [:index, :destroy]
    put 'settings/set', to: 'settings#set', as: :set_setting
    resources :histories, only: :index
  end

  get 'dashboard', to: 'dashboard#index'
  %w(compare_calendars alerts).each do |action|
    get "dashboard/#{action}", controller: 'dashboard', action: action
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'dashboard#index'

  # See how all your routes lay out with "rails routes"
end

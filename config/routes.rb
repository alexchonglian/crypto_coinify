require 'sidekiq/web'


Catarse::Application.routes.draw do
  def ssl_options
    if Rails.env.production? && CatarseSettings[:secure_host]
      {protocol: 'https', host: CatarseSettings[:secure_host]}
    else
      {}
    end
  end

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  devise_for(
      :users,
      {
          path: '',
          path_names:   { sign_out: :logout},
          controllers:  { omniauth_callbacks: :omniauth_callbacks, passwords: :passwords },
          defaults: ssl_options
      }
  )




  devise_scope :user do
    get '/sign_up_rewards', {to: 'users/registrations_rewards#new', as: :sign_up_rewards}
    get '/sign_in', {to: 'users/registrations_rewards#new', as: :sign_in}
    post '/sign_up', {to: 'devise/registrations#create', as: :sign_up}.merge(ssl_options)
  end

  # get "/sign_up_claim" => "devise/registrations#"


  get '/thank_you' => "static#thank_you"

  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  filter :locale, exclude: /\/auth\//

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount CatarsePaypalExpress::Engine => "/", as: :catarse_paypal_express
#  mount CatarseMoip::Engine => "/", as: :catarse_moip
#  mount CatarseWepay::Engine => "/", as: :catarse_wepay

  # Channels
  constraints subdomain: /^(?!www|secure|test|local)(\w+)/ do
    namespace :channels, path: '' do
      namespace :admin do
        namespace :reports do
          resources :subscriber_reports, only: [ :index ]
        end
        resources :posts
        resources :partners
        resources :followers, only: [ :index ]
        resources :projects, only: [ :index, :update] do
          member do
            put 'approve'
            put 'reject'
            put 'push_to_draft'
            put 'push_to_trash'
          end
        end
      end

      resources :posts
      get '/', to: 'profiles#show', as: :profile
      get '/how-it-works', to: 'profiles#how_it_works', as: :about
      resource :profile
      resources :projects, only: [:new, :create, :show] do
        collection do
          get 'video'
        end
      end
      # NOTE We use index instead of create to subscribe comming back from auth via GET
      resource :channels_subscriber, only: [:show, :destroy], as: :subscriber
    end
  end

  # Root path should be after channel constraintszom
  root to: 'projects#index'

  get "/explore" => "explore#index", as: :explore

  namespace :reports do
    resources :contribution_reports_for_project_owners, only: [:index]
  end

  namespace :api do
    get 'reward', to: 'koin#reward'
    post 'redeem', to: 'koin#redeem'
    get 'redeem_record', to: 'koin#redeem_record'
    get 'get_coin_info', to: 'koin#get_coin_info'
    resources :koin do
      member do
        get 'power'
      end
    end
    resources :counterpartyd do
        member do
        end
    end
  end

  resources :trades, only: [:index] do
      member do
      end
  end


  resources :coins, only: [:show] do
    member do
      get 'find'
    end
  end
  resources :projects, only: [:index, :create, :update, :new, :show] do
    resources :updates, controller: 'projects/updates', only: [ :index, :create, :destroy ]
    resources :rewards, only: [ :index, :create, :update, :destroy, :new, :edit ] do
      member do
        post 'sort'
      end
    end

    resources :contributions, {controller: 'projects/contributions'}.merge(ssl_options) do
      member do
        put 'credits_checkout'
        get 'success'
        post 'show'
      end
    end
    collection do
      get 'video'
    end
    member do
      put 'pay'
      get 'embed'
      get 'video_embed'
      get 'embed_panel'
      get 'send_to_analysis'
    end
  end
  resources :users do
    resources :projects, controller: 'users/projects', only: [ :index ]
    member do
      get :unsubscribe_notifications
      get :credits
    end
    collection do
      #get :get_coin_info
      get :uservoice_gadget
    end

    resources :usercoins, controller: 'users/usercoins', only: [:index, :create, :new, :show]

    resources :contributions, controller: 'users/contributions', only: [:index] do
      member do
        get :request_refund
      end
    end


    resources :unsubscribes, only: [:create]
    member do
      get 'projects'
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password', ssl_options
    end
  end

  namespace :admin do
    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
        put 'push_to_trash'
      end
    end

    resources :statistics, only: [ :index ]
    resources :financials, only: [ :index ]

    resources :contributions, only: [ :index, :update, :show ] do
      member do
        put 'confirm'
        put 'pendent'
        put 'change_reward'
        put 'refund'
        put 'hide'
        put 'cancel'
        put 'push_to_trash'
      end
    end
    resources :users, only: [ :index ]

    namespace :reports do
      resources :contribution_reports, only: [ :index ]
    end
  end

  get "/:permalink" => "projects#show", as: :project_by_slug
end
CatarsePaypalExpress::Engine.routes.draw do
  resources :paypal_express, only: [], path: 'payment/paypal_express' do
    collection do
      post :ipn
    end

    member do
      get  :review
      post :pay
      get  :success
      get  :cancel
    end
  end
end

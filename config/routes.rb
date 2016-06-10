Frasernw::Application.routes.draw do

  resources :videos

  resources :evidences

  match '/delayed_job' => DelayedJobWeb, anchor: false, via: [:get, :post]

  post '/versions/:id/revert' => 'versions#revert', as: 'revert_version'

  get '/versions' => 'versions#show_all', as: 'all_versions'
  get '/versions/:id' => 'versions#show', as: 'version'

  resources :user_masks, only: [:new, :create, :update] do
    collection do
      delete :destroy
    end
  end

  # temporary endpoint to develop the fnw datatable
  resources :data_tables, only: [] do
    collection do
      get :global_data
    end
  end

  resources :specializations, path: 'specialties' do
    resources :specialists
    resources :procedures, path: 'areas_of_practice'
    resources :clinics
  end

  resources :secret_tokens, only: [:create, :destroy]

  resources :latest_updates, only: [:index] do
    collection do
      patch :toggle_visibility
    end
  end

  resources :clinics do
    member do
      get :review
      get :rereview
      get :archive
      patch :accept, as: 'accept_review'
    end
  end

  scope '/clinics/:id/:token', controller: 'clinics' do
    get :refresh_cache
  end

  scope '/clinics/:id/:token', controller: 'clinics_editor' do
    # Secret edit or owner edit
    get :edit,    as: 'clinic_self_edit'
    patch :update,  as: 'clinic_self_update'
    get :pending, as: 'clinic_self_pending'
  end

  resources :specialists do
    member do
      get :review
      get :rereview
      get :archive
      patch :accept
      get :photo
      patch :update_photo
    end
  end

  scope '/specialists/:id/:token', controller: 'specialists' do
    get :refresh_cache
  end

  scope '/specialists/:id/:token', controller: 'specialists_editor' do
    # Secret edit or owner edit
    get :edit,    as: 'specialist_self_edit'
    patch :update,  as: 'specialist_self_update'
    get :pending, as: 'specialist_self_pending'
  end

  resources :procedures, path: 'areas_of_practice'
  resources :hospitals
  resources :languages
  resources :cities do
    resources :offices
  end
  resources :offices
  resources :provinces
  resources :healthcare_providers
  resources :divisions do
    resources :users
    member do
      get :edit_permissions
      patch :update_permissions
    end
  end

  resources :notes, only: [:create, :destroy]
  get '/history' => 'history#index'

  # until this controller action is finished
  # get '/analytics/' => 'analytics#show'

  get '/review_items/archived' => 'review_items#archived', as: 'archived_review_items'
  resources :review_items

  get '/feedback_items/archived' => 'feedback_items#archived', as: 'archived_feedback_items'
  resources :feedback_items

  resources :sc_categories, path: 'content_categories'
  get '/divisions/:id/content_items/' => 'sc_items#index', as: 'division_content_items'

  resources :demoable_content_items, only: [] do
    collection do
      get :edit
      patch :update
    end
  end

  resources :sc_items, path: 'content_items' do
    collection do
      get :bulk_share
    end
    member do
      patch :share, to: 'sc_items#share'

      # since emails can't 'put'
      get :share
    end
  end

  get '/divisions/:id/shared_content_items' => 'divisions#shared_sc_items', as: 'shared_content_items'
  patch '/divisions/:id/update_shared' => 'divisions#update_shared', as: 'update_shared'

  resources :subscriptions
  resources :news_items do
    member do
      get :update_borrowing
      post :copy
    end
  end
  resources :reports do
    collection do
      get :page_views
      get :sessions
      get :referents_by_specialty
      get :entity_page_views
      get :user_ids
      get :pageviews_by_user
    end
  end


  resources :referral_forms, only: [:index] do
    # Polymorphic routes
    collection do
      get :edit
      patch :update
    end
  end

  get '/specialists/:id/office/:office_id/print' => 'specialists#print_office_information',
    as: 'specialist_office_information'
  get '/specialists/:id/clinic/:clinic_id/location/:location_id/print' => 'specialists#print_clinic_information',
    as: 'specialist_clinic_information'
  get '/clinics/:id/location/:location_id/print' => 'clinics#print_location_information',
    as: 'clinic_location_information'

  get '/hospitals/:id/:token/refresh_cache' => 'hospitals#refresh_cache', as: 'hospital_refresh_cache'
  get '/languages/:id/:token/refresh_cache' => 'languages#refresh_cache', as: 'language_refresh_cache'

  get '/specialties/:id/cities/:city_id' => 'specializations#city', as: 'specialization_city'

  #Used to cache fragments of admin All Specialists page
  get '/specialties/:specialization_id/:token/specialists/refresh_index_cache/:division_id' =>
    'specialists#refresh_index_cache', as: 'specialist_refresh_index_cache'

  #need improve performance:
  patch '/favorites/specialists/:id' => 'favorites#edit', as: 'specialist_favorite', model: 'specialists'
  patch '/favorites/clinics/:id' => 'favorites#edit', as: 'clinic_favorite', model: 'clinics'
  patch '/favorites/content_items/:id' => 'favorites#edit', as: 'content_items_favorite', model: 'sc_items'

  get '/content_items/:id/email' => 'mail_to_patients#new',   as: 'compose_mail_to_patients'
  post '/mail_to_patients/create' => 'mail_to_patients#create', as: 'send_mail_to_patients'

  patch '/validate' => 'users#validate', as: :validate
  patch '/setup' => 'users#setup', as: :setup
  get '/change_local_referral_area' => 'users#change_local_referral_area', as: :change_local_referral_area
  patch '/update_local_referral_area' => 'users#update_local_referral_area', as: :update_local_referral_area
  get '/change_password' => 'users#change_password', as: :change_password
  patch '/update_password' => 'users#update_password', as: :update_password
  get '/change_email' => 'users#change_email', as: :change_email
  patch '/update_email' => 'users#update_email', as: :update_email
  get '/change_name' => 'users#change_name', as: :change_name
  patch '/update_name' => 'users#update_name', as: :update_name
  resources :password_resets, only: [ :new, :create, :edit, :update ]

  get '/logout' => 'user_sessions#destroy', as: :logout
  get '/login' => 'user_sessions#new', as: :login

  get '/livesearch_all_entries' => 'search#livesearch_all_entries', as: :livesearch_all_entries
  get '/refresh_livesearch_all_entries/:specialization_id' => 'search#refresh_livesearch_all_entries',
    as: :refresh_livesearch_all_entries

  root :to => 'front#index'

  resources :featured_contents, only: [] do
    collection do
      get :edit
      patch :update
    end
  end

  resources :terms_and_conditions, only: [:index]

  get '/stats' => 'stats#index', as: :stats

  get 'contact' => "messages#new"
  resources :messages, only: [:create]

  resources :messages, only: [:new, :create]
  resources :user_sessions

  resources :users do
    collection do
      get :upload
      post :import
    end
  end

  resources :faq_categories, only: [:show] do
    member do
      post :update_ordering
    end
  end
  resources :faqs, only: [:new, :create, :edit, :update, :destroy]

  resources :csv_usage_reports, only: [:new, :create, :show]

  resources :newsletters, except: :show

  namespace :api do
    namespace :v1 do
      resources :reports, only: [] do
        collection do
          get :page_views
          get :sessions
          get :entity_page_views
          get :user_ids
          get :pageviews_by_user
        end
      end
    end
  end

  resources :issues do
    member do
      get :toggle_subscription
    end
  end
  resources :change_requests, only: [:index]

  if ENV['RAILS_ENV'] == 'test'
    get '/dangerously_import_db', to: 'tests#dangerously_import_db'
  end
end

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
  get '/your_clinics' => 'clinics#index_own', as: 'index_own_clinics'

  scope '/clinics/:id/:token', controller: 'clinics_editor' do
    get :edit, as: 'clinic_self_edit'
    patch :update, as: 'clinic_self_update'
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

  scope '/specialists/:id/:token', controller: 'specialists_editor' do
    get :edit, as: 'specialist_self_edit'
    patch :update, as: 'specialist_self_update'
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

  get '/review_items/archived' => 'review_items#archived',
    as: 'archived_review_items'
  resources :review_items

  resources :feedback_items

  resources :sc_categories, path: 'content_categories'
  get '/divisions/:id/content_items/' => 'sc_items#index',
    as: 'division_content_items'

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
      get :share
    end
  end

  get '/divisions/:id/shared_content_items' => 'divisions#shared_sc_items',
    as: 'shared_content_items'
  patch '/divisions/:id/update_shared' => 'divisions#update_shared',
    as: 'update_shared'

  resources :subscriptions
  resources :news_items do
    member do
      get :update_borrowing
      post :copy
    end
  end

  resources :reports, only: [:index] do
    collection do
      get :page_views
      get :sessions
      get :referents_by_specialty
      get :entity_page_views
      get :user_ids
      get :page_views_by_user
      get :specialist_contact_history
      get :specialist_wait_times
      get :clinic_wait_times
      get :entity_statistics
      get :change_requests
      get :csv_usage
      get :archived_feedback_items
    end
  end


  resources :referral_forms, only: [:index] do
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

  get '/specialties/:id/cities/:city_id' => 'specializations#city',
    as: 'specialization_city'

  patch '/favorites/specialists/:id' => 'favorites#edit',
    as: 'specialist_favorite',
    model: 'specialists'
  patch '/favorites/clinics/:id' => 'favorites#edit',
    as: 'clinic_favorite',
    model: 'clinics'
  patch '/favorites/content_items/:id' => 'favorites#edit',
    as: 'content_items_favorite',
    model: 'sc_items'

  get '/content_items/:id/email' => 'mail_to_patients#new',
    as: 'compose_mail_to_patients'
  post '/mail_to_patients/create' => 'mail_to_patients#create',
    as: 'send_mail_to_patients'

  patch '/validate' => 'users#validate', as: :validate
  patch '/setup' => 'users#setup', as: :setup
  get '/change_password' => 'users#change_password', as: :change_password
  patch '/update_password' => 'users#update_password', as: :update_password
  get '/change_email' => 'users#change_email', as: :change_email
  patch '/update_email' => 'users#update_email', as: :update_email
  get '/change_name' => 'users#change_name', as: :change_name
  patch '/update_name' => 'users#update_name', as: :update_name
  resources :password_resets, only: [ :new, :create, :edit, :update ]

  get '/logout' => 'user_sessions#destroy', as: :logout
  get '/login' => 'user_sessions#new', as: :login

  root to: 'front#index'

  resources :featured_contents, only: [] do
    collection do
      get :edit
      patch :update
    end
  end

  get :terms_and_conditions, controller: 'static_pages'
  get :info, to: 'static_pages#pathways_info', as: :pathways_info

  get :contact, to: 'static_pages#contact', as: :contact
  post :contact, to: 'feedback_items#create', as: :submit_contact

  resources :user_sessions, only: [:new, :create, :destroy]

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
          get :page_views_by_user
        end
      end
    end
  end

  resources :issues do
    member do
      get :toggle_subscription
    end
  end
  resources :change_requests, only: [:index, :show]

  scope '/clinics/:id/:token', controller: 'clinics' do
    get :refresh_cache
  end

  scope '/specialists/:id/:token', controller: 'specialists' do
    get :refresh_cache
  end

  post '/notifications' => 'notifications#notify'
end

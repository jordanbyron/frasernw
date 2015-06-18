Frasernw::Application.routes.draw do

  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post] # private delayed_job_web interface

  post '/versions/:id/revert' => 'versions#revert', :as => 'revert_version'

  match '/versions'                 => 'versions#show_all', :as => 'all_versions'
  match '/specialists/:id/versions' => 'versions#index',    :as => 'specialist_versions', :model => 'specialists'
  match '/clinics/:id/versions'     => 'versions#index',    :as => 'clinic_versions',     :model => 'clinics'
  match '/versions/:id'             => 'versions#show',     :as => 'show_version'

  resources :specializations, :path => 'specialties' do
    resources :specialists
    resources :procedures, :path => 'areas_of_practice'
    resources :clinics
  end

  resources :clinics do
    member do
      get :review
      get :rereview
      get :archive
      put :accept, as: "accept_review"
      get :print, as: "patient_information", action: "print_patient_information"
      get :edit_referral_forms, as: "referral_forms"
    end
  end

  scope "/clinics/:id/:token", controller: "clinics" do
    get :refresh_cache
  end

  scope "/clinics/:id/:token", controller: "clinics_editor" do
    # Secret edit or owner edit
    get :edit,        as: "clinic_self_edit"
    put :update,      as: "clinic_self_update"
    get :pending,     as: "clinic_self_pending"

    # update_all_specialists_and_clinic.rake
    get :temp_edit,   as: "clinic_temp_edit"
    put :temp_update, as: "clinic_temp_update"
  end

  resources :specialists do
    member do
      get :review
      get :rereview
      get :archive
      put :accept
      get :photo
      put :update_photo
      get :edit_referral_forms, as: "referral_forms"
    end
  end

  scope "/specialists/:id/:token", controller: "specialists" do
    get :refresh_cache
  end

  scope "/specialists/:id/:token", controller: "specialists_editor" do
    # Secret edit or owner edit
    get :edit,        as: "specialist_self_edit"
    put :update,      as: "specialist_self_update"
    get :pending,     as: "specialist_self_pending"

    # update_all_specialists_and_clinic.rake
    get :temp_edit,   as: "specialist_temp_edit"
    put :temp_update, as: "specialist_temp_update"
  end

  resources :procedures, :path => 'areas_of_practice'
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
  end

  # until this controller action is finished
  # get '/analytics/' => 'analytics#show'

  match '/review_items/archived' => 'review_items#archived', :as => 'archived_review_items'
  resources :review_items

  match '/feedback_items/archived' => 'feedback_items#archived', :as => 'archived_feedback_items'
  resources :feedback_items

  resources :sc_categories, :path => 'content_categories'
  match '/divisions/:id/content_items/' => 'sc_items#index', :as => 'division_content_items'
  resources :sc_items, :path => 'content_items'

  match '/divisions/:id/shared_content_items' => 'divisions#shared_sc_items', :as => 'shared_content_items'
  put   '/divisions/:id/update_shared' => 'divisions#update_shared', :as => 'update_shared'

  #match 'subscriptions' => 'subscriptions#show', :as => 'subscriptions', :via => :get
  resources :notifications
  resources :subscriptions
  resources :news_items
  resources :reports


  match '/referral_forms'               => 'referral_forms#index',      :as => 'referral_forms'

  match '/specialists/:id/print'        => 'specialists#print_patient_information',   :as => 'specialist_patient_information'
  match '/specialists/:id/print/office/:office_id' => 'specialists#print_office_patient_information',   :as => 'specialist_patient_information_office'
  match '/clinics/:id/print/location/:location_id'  => 'clinics#print_location_patient_information',       :as => 'clinic_patient_information_location'

  get  '/specialties/:id/:token/refresh_cache'     => 'specializations#refresh_cache', :as => 'specialization_refesh_cache'
  get  '/hospitals/:id/:token/refresh_cache'       => 'hospitals#refresh_cache',       :as => 'hospital_refesh_cache'
  get  '/languages/:id/:token/refresh_cache'       => 'languages#refresh_cache',       :as => 'language_refesh_cache'

  get  '/specialties/:id/cities/:city_id' => 'specializations#city', :as => 'specialization_city'

  #need improve performance:
  get  '/specialties/:id/:token/refresh_city_cache/:city_id' => 'specializations#refresh_city_cache', :as => 'specialization_refresh_city_cache'
  get  '/specialties/:id/:token/refresh_division_cache/:division_id' => 'specializations#refresh_division_cache', :as => 'specialization_refresh_division_cache'

  put  '/favorites/specialists/:id' => 'favorites#edit', :as => 'specialist_favorite', :model => 'specialists'
  put  '/favorites/clinics/:id' => 'favorites#edit', :as => 'clinic_favorite', :model => 'clinics'
  put  '/favorites/content_items/:id' => 'favorites#edit', :as => 'content_items_favorite', :model => 'sc_items'

  match '/content_items/:id/email'      => 'mail_to_patients#new',   :as => 'compose_mail_to_patients'
  post  '/mail_to_patients/create'     => 'mail_to_patients#create', :as => 'send_mail_to_patients'

  match '/validate' => 'users#validate', :as => :validate
  match '/setup' => 'users#setup', :as => :setup
  get   '/change_local_referral_area' => 'users#change_local_referral_area', :as => :change_local_referral_area
  put   '/update_local_referral_area' => 'users#update_local_referral_area', :as => :update_local_referral_area
  get   '/change_password' => 'users#change_password', :as => :change_password
  put   '/update_password' => 'users#update_password', :as => :update_password
  get   '/change_email' => 'users#change_email', :as => :change_email
  put   '/update_email' => 'users#update_email', :as => :update_email
  get   '/change_name' => 'users#change_name', :as => :change_name
  put   '/update_name' => 'users#update_name', :as => :update_name
  resources :password_resets, :only => [ :new, :create, :edit, :update ]

  match '/logout' => 'user_sessions#destroy', :as => :logout
  match '/login' => 'user_sessions#new', :as => :login

  match '/livesearch' => 'search#livesearch', :as => :livesearch
  match '/livesearch_all_entries' => 'search#livesearch_all_entries', :as => :livesearch_all_entries
  match '/refresh_livesearch_global' => 'search#refresh_livesearch_global', :as => :refresh_livesearch_global
  match '/refresh_livesearch_all_entries/:specialization_id' => 'search#refresh_livesearch_all_entries', :as => :refresh_livesearch_all_entries
  match '/refresh_livesearch_division_entries/:division_id/:specialization_id' => 'search#refresh_livesearch_division_entries', :as => :refresh_livesearch_division_entries
  match '/refresh_livesearch_division_content/:division_id' => 'search#refresh_livesearch_division_content', :as => :refresh_livesearch_division_content

  match '/front' => 'front#index', :as => :front
  get '/front/:division_id' => 'front#as_division', :as => :front_as_division
  match '/faq' => 'front#faq', :as => :faq
  match '/terms_and_conditions' => 'front#terms_and_conditions', :as => :terms_and_conditions
  match '/front/edit/:division_id' => 'front#edit', :as => :edit_front_as_division
  match '/front/update' => 'front#update', :as => :update_front
  match '/stats' => 'stats#index', :as => :stats

  match 'messages' => 'messages#new', :as => 'messages', :via => :get
  match 'messages' => 'messages#create', :as => 'messages', :via => :post

  resources :user_sessions

  resources :users do
    collection do
      get :upload
      post :import
    end
  end

  root :to => 'front#index'
end

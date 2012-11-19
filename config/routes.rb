Frasernw::Application.routes.draw do

  post "versions/:id/revert" => "versions#revert", :as => "revert_version"

  match "/versions"                 => "versions#show_all", :as => "all_versions"
  match "/specialists/:id/versions" => "versions#index",    :as => "specialist_versions", :model => 'specialists'
  match "/clinics/:id/versions"     => "versions#index",    :as => "clinic_versions",     :model => 'clinics'
  match "/versions/:id"             => "versions#show",     :as => "show_version"

  resources :specializations, :path => 'specialties' do
    resources :specialists
    resources :procedures, :path => 'areas_of_practice'
    resources :clinics
  end
  resources :clinics
  resources :specialists
  resources :procedures, :path => 'areas_of_practice'
  resources :hospitals
  resources :languages
  resources :cities do
    resources :offices
  end
  resources :offices
  resources :provinces
  resources :healthcare_providers
  resources :divisions
  
  match "/review_items/archived" => "review_items#archived", :as => "archived_review_items"
  resources :review_items
  
  match "/feedback_items/archived" => "feedback_items#archived", :as => "archived_feedback_items"
  resources :feedback_items
  
  resources :sc_categories, :path => 'content_categories'
  resources :sc_items, :path => 'content_items'
  
  resources :news_items
  
  match "specialists/:id/:token/edit"   => 'specialists_editor#edit',   :as => 'specialist_self_edit'
  put   "specialists/:id/:token/update" => 'specialists_editor#update', :as => 'specialist_self_update'
  get   "specialists/:id/:token/pending"=> 'specialists_editor#pending',:as => 'specialist_self_pending'
  match "specialists/:id/review"        => 'specialists#review',        :as => 'specialist_review'
  match "specialists/:id/accept"        => 'specialists#accept',        :as => 'specialist_accept_review'
  match "specialists/:id/photo"         => 'specialists#photo',         :as => 'specialist_photo'
  put   "specialists/:id/update_photo"  => 'specialists#update_photo',  :as => 'specialist_update_photo'
  
  match "clinics/:id/:token/edit"       => 'clinics_editor#edit',       :as => 'clinic_self_edit'
  put   "clinics/:id/:token/update"     => 'clinics_editor#update',     :as => 'clinic_self_update'
  get   "clinics/:id/:token/pending"    => 'clinics_editor#pending',    :as => 'clinic_self_pending'
  match "clinics/:id/review"            => 'clinics#review',            :as => 'clinic_review'
  match "clinics/:id/accept"            => 'clinics#accept',            :as => 'clinic_accept_review'
  
  match "/specialists/:id/edit_referral_forms"  => "specialists#edit_referral_forms", :as => "specialist_referral_forms"
  match "/clinics/:id/edit_referral_forms"      => "clinics#edit_referral_forms",     :as => "clinic_referral_forms"
  
  match "/specialists/:id/print"        => "specialists#print_patient_information",   :as => "specialist_patient_information"
  match "/clinics/:id/print"            => "clinics#print_patient_information",       :as => "clinic_patient_information"
  
  get  "specialties/:id/:token/refresh_cache" => 'specializations#refresh_cache', :as => 'specialization_refesh_cache'
  get  "specialists/:id/:token/refresh_cache"     => 'specialists#refresh_cache',     :as => 'specialist_refesh_cache'
  get  "clinics/:id/:token/refresh_cache"         => 'clinics#refresh_cache',         :as => 'clinic_refesh_cache'
  get  "hospitals/:id/:token/refresh_cache"       => 'hospitals#refresh_cache',       :as => 'hospital_refesh_cache'
  get  "areas_of_practice/:id/:token/refresh_cache"      => 'procedures#refresh_cache',      :as => 'procedure_refesh_cache'
  get  "languages/:id/:token/refresh_cache"       => 'languages#refresh_cache',       :as => 'language_refesh_cache'
  
  put  "/favorites/specialists/:id" => "favorites#edit", :as => "specialist_favorite", :model => 'specialists'
  put  "/favorites/clinics/:id" => "favorites#edit", :as => "clinic_favorite", :model => 'clinics'
  put  "/favorites/content_items/:id" => "favorites#edit", :as => "content_items_favorite", :model => 'sc_items'
  
  match "content_items/:id/email"      => 'mail_to_patients#new',   :as => 'compose_mail_to_patients'
  post  "mail_to_patients/create"     => 'mail_to_patients#create', :as => 'send_mail_to_patients'
  
  match 'validate' => 'users#validate', :as => :validate
  match 'setup' => 'users#setup', :as => :setup
  get 'change_local_referral_area' => 'users#change_local_referral_area', :as => :change_local_referral_area
  put 'update_local_referral_area' => 'users#update_local_referral_area', :as => :update_local_referral_area
  get 'change_password' => 'users#change_password', :as => :change_password
  put 'update_password' => 'users#update_password', :as => :update_password
  get 'change_email' => 'users#change_email', :as => :change_email
  put 'update_email' => 'users#update_email', :as => :update_email
  get 'change_name' => 'users#change_name', :as => :change_name
  put 'update_name' => 'users#update_name', :as => :update_name
  resources :password_resets, :only => [ :new, :create, :edit, :update ]

  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'login' => 'user_sessions#new', :as => :login
  
  match 'livesearch' => 'search#livesearch', :as => :livesearch
  
  match 'front' => 'front#index', :as => :front
  match 'faq' => 'front#faq', :as => :faq
  match 'terms_and_conditions' => 'front#terms_and_conditions', :as => :terms_and_conditions
  match 'front/edit' => 'front#edit', :as => :edit_front
  match 'front/update' => 'front#update', :as => :update_front
  match 'stats' => 'stats#index', :as => :stats

  resources :user_sessions

  resources :users

  root :to => 'front#index'
end

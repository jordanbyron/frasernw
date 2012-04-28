Frasernw::Application.routes.draw do

  resources :reviews, :only => [:index, :destroy] do
    put :accept
  end

  post "versions/:id/revert" => "versions#revert", :as => "revert_version"

  match "/versions"                 => "versions#show_all", :as => "all_versions"
  match "/specialists/:id/versions" => "versions#index",    :as => "specialist_versions", :model => 'specialists'
  match "/clinics/:id/versions"     => "versions#index",    :as => "clinic_versions",     :model => 'clinics'
  match "/versions/:id"             => "versions#show",     :as => "show_version"

  resources :specializations do
    resources :specialists
    resources :procedures
    resources :clinics
  end
  resources :clinics
  resources :specialists
  resources :procedures
  resources :hospitals
  resources :languages
  resources :cities do
    resources :offices
  end
  resources :offices
  resources :provinces
  resources :healthcare_providers
  resources :review_items

  match "tracker" => 'tracker#index', :as => 'tracker'
  
  match "specialists/:id/:token/edit"   => 'specialists_editor#edit',  :as => 'specialist_self_edit'
  put  "specialists/:id/:token/update"  => 'specialists_editor#update', :as => 'specialist_self_update'
  get  "specialists/:id/:token/refresh_cache" => 'specialists#refresh_cache', :as => 'specialist_refesh_cache', :ajax_layout => 'true'
  get  "specialists/email/:id"          => 'specialists#email', :as => 'specialist_email'
  match "specialists/:id/review"        => 'specialists#review', :as => 'specialist_review'
  
  match "/specialists/:id/edit_referral_forms" => "specialists#edit_referral_forms",  :as => "specialist_referral_forms"
  match "/clinics/:id/edit_referral_forms" => "clinics#edit_referral_forms",          :as => "clinic_referral_forms"
  
  #RPW TODO: allow users to edit their own profile
  #match 'user/edit' => 'users#edit', :as => :edit_current_user

  match 'signup' => 'users#new', :as => :signup

  match 'logout' => 'user_sessions#destroy', :as => :logout
  
  match 'login' => 'user_sessions#new', :as => :login
  
  match 'livesearch' => 'search#livesearch', :as => :livesearch
  
  match 'front' => 'front#index', :as => :front

  resources :user_sessions

  resources :users

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
  root :to => 'front#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

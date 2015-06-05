Rails.application.routes.draw do

  get 'questions/show'

	#  disable registration, but allow for password change 
	#  https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
	devise_for :users, :skip => [:registrations] 
		as :user do
			get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'    
			put 'users/:id' => 'devise/registrations#update', :as => 'user_registration'  
		end

	root to: "questions#home"
	resources :questions, except: [:index]

	match "/questions/:id", to: "questions#show", via: :get

	# API-like routes
	# User 
	match "/api/user/current", to: "users#get_current_user", via: :get
	# Questions
	match "/api/questions/:category/:status", to: "questions#get_questions", via: :get
	match "/api/questions/:id", to: "questions#get_current_question", via: :get
	match "/api/questions", to: "questions#create_question", via: :post
	match "/api/questions/:id/reply", to: "questions#create_question_reply", via: :post
	match "/api/questions/:id/get/replies", to: "questions#get_question_replies", via: :get
	match "/api/questions/:id/answer", to: "questions#answer", via: :post
	# Categories
	match "/api/categories", to: "categories#get_categories", via: :get
	match "/api/categories/create", to: "categories#create_category", via: :post
	# User
	match "/api/users", to: "users#create_user", via: :post
	# END API-like routes

end

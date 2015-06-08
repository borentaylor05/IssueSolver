class UsersController < ApplicationController

	def get_current_user
		if user_signed_in?
			respond({ status: 0, user: current_user })
		else
			respond({ status: 1, error: "User not signed in" })
		end
	end

	def create_user
		 u = User.find_by(employee_id: params[:employee_id])
		 if u 
		 	respond({ status: 1, error: "User #{params[:employee_id]} already exists. " })
		 elsif params[:l2] and params[:mentor]
		 	respond({ status: 1, error: "User cannot be L2 and Coach Mentor." })
		 else
		 	if params[:password] == params[:password_confirmation]
			 	u = User.new(
			 		name: "#{params[:first_name]} #{params[:last_name]}",
			 		jive_id: params[:jive_id] ||= 0,
			 		employee_id: params[:employee_id],
			 		mentor: params[:mentor] ? true : false,
			 		l2: params[:l2] ? true : false,
			 		email: params[:email],
			 		password: params[:password]
			 	)
			 	if u.valid?
			 		u.save
			 		respond({ status: 0, user: u })
			 	else
			 		respond({ status: 1, error: u.errors.full_messages })
			 	end
			 else
			 	respond({ status: 1, error: "Passwords do not match." })
			 end
		 end
	end

	def got_it
		if current_user.update_attributes(how_to: true)
			respond({ status: 0 })
		end
	end

end

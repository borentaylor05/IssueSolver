class UsersController < ApplicationController

	def get_current_user
		if user_signed_in?
			respond({ status: 0, user: current_user })
		else
			respond({ status: 1, error: "User not signed in" })
		end
	end

end

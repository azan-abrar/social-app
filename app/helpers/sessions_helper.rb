module SessionsHelper
	# Logs in the given user
	def log_in(user)
		session[:user_id] = user.id
	end

	# Return the logged-in user if any otherwise return nil
	def current_user
		@current_user ||= User.find_by(id: session[:user_id])
	end

	# Check whether the user is logged-in or not, returns true or false
	def logged_in?
		!current_user.nil?
	end

	def log_out
		session.delete(:user_id)
		@current_user = nil
	end

end

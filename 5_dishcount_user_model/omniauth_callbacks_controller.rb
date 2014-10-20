class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

	def all
		user = User.from_omniauth(request.env["omniauth.auth"])
		# if the user is already saved to the database
		# and doesn't have unsaved changes, the user has logged in using Facebook before
		if user.persisted? && !user.changed?
			sign_in_and_redirect user
		else
			if user.email && User.new_email(user.email) 
				# if the user has an email and it is new, create a new user record
				user = User.create_from_facebook(request.env["omniauth.auth"])
				sign_in_and_redirect user
			elsif user.email
				# otherwise if the user has an email, it must not be a new email;
				# the existing account must have used email and password authentication
				# merge the existing account with the new Facebook data
				session["facebook_data"] = user.attributes
				redirect_to new_user_session_url
			else
				# Facebook didn't provide an email address
				# Email must be provided manually by the user
				session["devise.user_attributes"] = user.attributes
				redirect_to new_user_registration_url
			end
		end
	end

  alias_method :facebook, :all

end
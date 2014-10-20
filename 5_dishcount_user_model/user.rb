class User < ActiveRecord::Base
	# a user can have many favourites
	has_many :favourites
	# a user can have many restaurants through favourites
	has_many :restaurants, :through => :favourites
	# a user can make many recommendations
	has_many :recommendations
	# each recommendation belongs to an offer
	has_many :offers, :through => :recommendations
	# if the user is a restaurant owner, they can own one restaurant
	has_one :restaurant, foreign_key: "owner_id"
	# a user can make many reviews
	has_many :reviews
	# each review belongs to an offer
	has_many :offers, :through => :reviews
	# a user can have many saved_offers
	has_many :saved_offers
	# each saved_offer belongs to an offer
	has_many :offers, :through => :saved_offers
	# a user can have many pictures
	has_many :pictures
	# used for email confirmation upon sign-up
	attr_accessor :email_repeat
	# ensure the emails match when signing up
	validate :check_email_match, on: :create
	# include the following devise modules
  devise :database_authenticatable, :registerable,
	       :recoverable, :rememberable, :trackable, :validatable,
	       :omniauthable

	# return a user for Facebook login
	def self.from_omniauth(auth)
		# try to match on Facebook UID
		user = where(auth.slice(:uid)).first
		# if no user is found using Facebook UID, find based on email; if new email, create a new user
		user = user || find_or_initialize_by(email: auth[:info][:email])
		# if the user doesn't have a UID, they haven't logged in with facebook before; set the attributes
		unless user.uid
			user.provider = 'facebook'
			user.uid = auth.uid
		# otherwise, the user has logged in with facebook before
		else
			# this is a sanity check; the condition should always return false
			if user.uid != auth[:uid]
				raise 'conflict between persisted data and Facebook API reply'
			end
		end
		# return the user
		user
	end

	# if the email belongs to an existing user, return false; otherwise return true
 	def self.new_email(email)
 		where(email: email).first ? false : true
 	end
 
 	# save a new user from Facebook
 	def self.create_from_facebook(attributes)
 		create! do |user|
 			user.email = attributes[:info][:email]
 			user.provider = 'facebook'
 			user.uid = attributes.uid
 		end
 	end

 	# when signing up with Facebook, sometimes no email is provided by the API
 	# when this happens, the Facebook callback object is saved in a session so the user
 	# can enter the email manually into the form and create an account
	def self.new_with_session(params, session)
		if session["devise.user_attributes"]
			new(session["devise.user_attributes"]) do |user|
				user.attributes = params
				user.valid?
			end
		else
			super
		end
	end

	# the password is not required when logging in with Facebook
	def password_required?
		super && provider.blank?
	end

	# if a user has only ever signed in using Facebook, they have no password.
	# they can update their account information without entering a password.
	def update_with_password(params, *options)
		if encrypted_password.blank?
			update_attributes(params, *options)
		else
			super
		end
	end

	# when signing up with email and password, the email must match the repeat email field
	# when signing up with Facebook, there is no need to check the repeat email field
	def check_email_match
		if provider.blank?
  		errors.add(:email, "error: los dos correos no son idénticos, por favor, escriba y repita de nuevo su email") if email != email_repeat
  	end
	end

	# returns true if the user is an admin user
  def is_admin?
  	self.email && ENV['ADMIN_EMAILS'].to_s.include?(self.email)
	end

	# returns the number of offers the user with id 'id' has saved
	def total_saved
    SavedOffer.where(user_id: id).count
	end

	# returns the number of reviews the user with id 'id' has written
	def total_reviewed
		Review.where(user_id: id).count
	end

end
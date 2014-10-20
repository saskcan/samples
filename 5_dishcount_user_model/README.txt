File:
'user.rb'

The 'user' model code for Dishcount. Sets up associations between the Users table in the database and related tables. Specifies validation checks for creating and editing instances of a User record. Also includes code for creation of new User records through the Facebook API. Uses the 'Devise' gem ("https://github.com/plataformatec/devise") as well as the 'Omniauth-facebook' gem ("https://github.com/mkdynamic/omniauth-facebook") for Facebook login.

File:
'omniauth_callbacks_controller.rb'

Provides propper handling of Omniauth callback for Facebook sign-up and login.
# Sign in with credentials.
#
# @param email [String]
# @param password [String]
def sign_in_with(email, password)
  visit '/sign_in'
  fill_in 'E-mail', with: email
  fill_in 'Password', with: password
  click_button 'Sign in'
end


# Create user, sign in with it and return it.
#
# @param email [String]
# @param password [String]
#
# @return [User]
def we_are_signed_in_user(email: 'example@email.net', password: 'password')
  user = FactoryGirl.create(:user, email: email, password: password)
  sign_in_with(email, password)
  user
end


# Sign out if we are signed in.
def sign_out_if_signed_in
  visit '/'
  click_on('Profile') if page.has_link?('Profile')
  click_on('Sign out') if page.has_link?('Sign out')
end
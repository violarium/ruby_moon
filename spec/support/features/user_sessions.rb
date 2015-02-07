# Sign in with credentials.
def sign_in_with(email, password)
  visit '/sign_in'
  fill_in 'E-mail', with: email
  fill_in 'Password', with: password
  click_button 'Sign in'
end

# Create user, sign in with it and return it.
def we_are_signed_in_user(email: 'example@email.net', password: 'password')
  user = User.create!(email: email, password: password)
  sign_in_with(email, password)
  user
end
# Sign in with credentials.
def sign_in_with(email, password)
  visit '/sign_in'
  fill_in 'E-mail', with: email
  fill_in 'Password', with: password
  click_button 'Sign in'
end
# Sign in user for controller tests.
def controller_sign_in(user = nil)
  user = User.create! if user.nil?
  session[:user_id] = user.id
  user
end
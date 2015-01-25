# Sign in user for controller tests.
def controller_sign_in(user)
  session[:user_id] = user.id
end
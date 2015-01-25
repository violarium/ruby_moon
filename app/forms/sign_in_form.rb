# Form for sign in process.
class SignInForm

  # Submit sign in credentials and return nil or User.
  def submit(params)
    user = User.where(email: params[:email]).first
    if user && !user.password.nil? && user.password == params[:password]
      user
    else
      nil
    end
  end
end
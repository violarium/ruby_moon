# Form for sign in process.
class SignInForm
  include FormObject

  attr_accessor :email, :password, :remember


  # Submit sign in credentials and return nil or User.
  def submit
    user = User.where(email: email).first
    if user && !user.password.nil? && user.password == password
      user
    else
      errors.add(:base, :invalid_credentials)
      nil
    end
  end
end
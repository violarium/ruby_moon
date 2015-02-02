# Form for sign in process.
class SignInForm
  include ActiveModel::Model
  include ActionView::Helpers

  delegate :email, :password, to: :form_params

  # Submit sign in credentials and return nil or User.
  def submit(params)
    @form_params = SignInStorage.new(params[:email], params[:password])
    user = User.where(email: form_params.email).first
    if user && !user.password.nil? && user.password == form_params.password
      user
    else
      errors.add(:base, t('forms.sign_in_form.invalid_credentials'))
      nil
    end
  end

  protected

  def form_params
    @form_params ||= SignInStorage.new
  end

  class SignInStorage < Struct.new(:email, :password); end
end
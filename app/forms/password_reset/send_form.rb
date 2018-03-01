module PasswordReset
  class SendForm
    include FormObject

    attr_accessor :email

    def initialize(params = {})
      super(params.slice(:email))
    end

    def submit
      user = User.where(email: email).first
      if user.nil?
        errors.add(:base, :no_user_with_such_email)
        false
      else
        user.generate_reset_password
        ResetPasswordMailer.send_reset_link(user).deliver_now
        true
      end
    end
  end
end
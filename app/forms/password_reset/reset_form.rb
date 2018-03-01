module PasswordReset
  class ResetForm
    include FormObject

    attr_reader :user
    attr_accessor :new_password, :new_password_confirmation

    validates :new_password, presence: true, confirmation: true

    def initialize(user, params = {})
      @user = user
      super(params.slice(:new_password, :new_password_confirmation))
    end

    def submit
      if valid?
        @user.password = new_password
        @user.password_confirmation = new_password_confirmation
        @user.reset_password_token = nil
        @user.reset_password_at = nil
        @user.save!
        true
      else
        false
      end
    end
  end
end
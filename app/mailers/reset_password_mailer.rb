class ResetPasswordMailer < ApplicationMailer
  def send_reset_link(user)
    raise ArgumentError, 'User has no reset password token' if user.reset_password_token.nil?
    @user = user
    I18n.with_locale(user.locale) do
      @subject = t('mailers.reset_password.send_reset_link.subject')
      mail(to: user.email, subject: @subject)
    end
  end
end
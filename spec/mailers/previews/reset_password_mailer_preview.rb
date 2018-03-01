# Preview all emails at http://localhost:3000/rails/mailers/reset_password_mailer
class ResetPasswordMailerPreview < ActionMailer::Preview
  User::ALLOWED_LOCALES.keys.each do |locale|
    define_method "send_reset_link_#{locale}" do
      user = User.where(email: 'example@email.net').first
      user.delete unless user.nil?

      user = User.create!(email: 'example@email.net', password: '123456', reset_password_token: 'token', locale: locale)

      ResetPasswordMailer.send_reset_link(user)
    end
  end
end

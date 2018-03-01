require 'rails_helper'

describe PasswordReset::SendForm do
  describe 'when parameters are correct' do
    let!(:user) { FactoryGirl.create(:user, email: 'email@example.net', password: 'password') }
    let!(:form) { PasswordReset::SendForm.new(email: 'email@example.net') }

    it 'should return true' do
      expect(form.submit).to eq true
    end

    it 'should generate reset information for user' do
      form.submit
      user.reload
      expect(user.reset_password_token).not_to be_nil
      expect(user.reset_password_at).not_to be_nil
    end

    it 'should send email' do
      mailer = double('mailer')
      expect(ResetPasswordMailer).to receive(:send_reset_link).with(user).and_return(mailer)
      expect(mailer).to receive(:deliver_now)
      form.submit
    end
  end

  describe 'when parameters are not correct' do
    let!(:form) { PasswordReset::SendForm.new(email: 'email@example.net') }

    it 'should return false' do
      expect(form.submit).to eq false
    end

    it 'should not send email' do
      expect(ResetPasswordMailer).not_to receive(:send_reset_link)
      form.submit
    end
  end
end
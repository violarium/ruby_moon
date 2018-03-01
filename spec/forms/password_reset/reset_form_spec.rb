require 'rails_helper'

describe PasswordReset::ResetForm do
  describe 'when parameters are correct' do
    let!(:user) { FactoryGirl.create(:user,
                                     email: 'email@example.net',
                                     password: 'password',
                                     reset_password_token: '123',
                                     reset_password_at: Time.now) }
    let!(:form) { PasswordReset::ResetForm.new(user,
                                               new_password: 'new_password',
                                               new_password_confirmation: 'new_password') }

    it 'should make form valid' do
      expect(form).to be_valid
    end

    it 'should return true on submit' do
      expect(form.submit).to eq true
    end

    it 'should change password' do
      form.submit
      user.reload
      expect(user.password == 'new_password').to be_truthy
    end

    it 'should clear reset password fields' do
      form.submit
      user.reload
      expect(user.reset_password_token).to be_nil
      expect(user.reset_password_at).to be_nil
    end
  end

  describe 'when parameters are not correct' do
    let!(:user) { FactoryGirl.create(:user, email: 'email@example.net', password: 'password') }

    shared_examples 'invalid form data' do
      it 'should not be valid' do
        expect(form).not_to be_valid
      end

      it 'should not change user password on submit' do
        expect(form.submit).to be_falsey

        user.reload
        expect(user.password).to eq 'password'
      end
    end

    describe 'when passwords do not match' do
      let!(:form) { PasswordReset::ResetForm.new(user, new_password: 'new_password', new_password_confirmation: '123') }
      include_examples 'invalid form data'
    end

    describe 'when passwords are empty' do
      let!(:form) { PasswordReset::ResetForm.new(user, new_password: '', new_password_confirmation: '') }
      include_examples 'invalid form data'
    end
  end
end
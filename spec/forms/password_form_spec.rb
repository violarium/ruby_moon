require 'rails_helper'

describe PasswordForm do
  let(:user) { FactoryGirl.create(:user, password: '123456', password_confirmation: '123456') }

  shared_examples 'invalid form data' do
    it 'should not be valid' do
      expect(form).not_to be_valid
    end

    it 'should not change user password on submit' do
      expect(form.submit).to be_falsey

      user.reload
      expect(user.password).to eq '123456'
    end
  end

  describe 'when everything is fine' do
    let(:form) { PasswordForm.new(user, { current_password: '123456',
                                          new_password: 'pass',
                                          new_password_confirmation: 'pass' }) }
    it 'should be valid' do
      expect(form).to be_valid
    end

    it 'should change user password on submit' do
      expect(form.submit).to be_truthy

      user.reload
      expect(user.password).to eq 'pass'
    end
  end

  describe 'when current password do not match password' do
    let(:form) { PasswordForm.new(user, { current_password: nil,
                                          new_password: 'pass',
                                          new_password_confirmation: 'pass' }) }
    include_examples 'invalid form data'
  end

  describe 'when new password is not confirmed' do
    let(:form) { PasswordForm.new(user, { current_password: '123456',
                                          new_password: 'pass',
                                          new_password_confirmation: 'p' }) }
    include_examples 'invalid form data'
  end
end
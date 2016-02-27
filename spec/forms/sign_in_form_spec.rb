require 'rails_helper'

describe SignInForm do
  describe 'param access' do
    it 'should return empty parameters by default' do
      form = SignInForm.new

      expect(form.email).to be_nil
      expect(form.password).to be_nil
      expect(form.remember).to be_nil
    end

    it 'should return submitted parameters after submit' do
      form = SignInForm.new(email: 'email', password: 'password', remember: true)

      expect(form.email).to eq 'email'
      expect(form.password).to eq 'password'
      expect(form.remember).to eq true
    end
  end


  describe 'submission' do
    it 'should return user when params are correct' do
      user = FactoryGirl.create(:user, password: 'password')
      form = SignInForm.new(email: user.email, password: 'password')

      expect(form.submit).to eq user
    end

    describe 'incorrect params' do
      it 'should return nil when email is incorrect' do
        form = SignInForm.new(email: 'example@email.net', password: 'password')

        expect(form.submit).to be_nil
      end

      it 'should return nil when password is incorrect' do
        user = FactoryGirl.create(:user, password: 'password')
        form = SignInForm.new(email: user.email, password: 'invalid')

        expect(form.submit).to be_nil
      end
    end

    it 'should return nil when existing user password is nil and sent password is nil' do
      user = FactoryGirl.build(:corrupt_password_user)
      user.save!(validate: false)
      expect(user.password).to be_nil

      form = SignInForm.new(email: user.email)
      expect(form.submit).to be_nil
    end
  end
end
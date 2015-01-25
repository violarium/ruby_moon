require 'rails_helper'

describe User do
  it 'should have unique email' do
    User.create(email: 'example@email.org')
    expect { User.create(email: 'example@email.org') }.to raise_error(Moped::Errors::OperationFailure)
  end

  describe 'password hashing' do

    it 'should encrypt the password' do
      expect(::BCrypt::Password).to receive(:create).with('password').and_return('encrypted password')
      user = User.create(password: 'password')
      expect(user.encrypted_password).to eq 'encrypted password'
    end

    it 'should compare encrypted password with actual correctly' do
      user = User.create(password: 'password')
      expect(user.password == 'password').to eq true
    end

    it 'should work correctly when corrupt encrypted password is stored' do
      user = User.create(encrypted_password: 'bad')
      expect(user.password).to be_nil
    end
  end
end
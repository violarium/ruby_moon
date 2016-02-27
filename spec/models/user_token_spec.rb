require 'rails_helper'

describe UserToken do
  describe 'token' do
    it 'should encrypt the token' do
      token_hash = ::Digest::SHA2.hexdigest('token')
      token = UserToken.create!(token: 'token')
      expect(token.encrypted_token).to eq token_hash
    end

    it 'is required' do
      token = UserToken.new
      expect(token).not_to be_valid
    end

    it 'should be unique' do
      UserToken.create!(token: 'token')
      token = UserToken.new(token: 'token')

      expect(token).not_to be_valid
    end
  end


  describe 'expiration' do
    it 'sets expiration time on create' do
      Timecop.freeze(Time.new(2015, 1, 1)) do
        token = UserToken.create!(token: 'token')
        expect(token.expires_at).to eq (Time.new(2015, 1, 1) + UserToken::LIFETIME_DAYS.days)
      end
    end

    it 'des not set expiration time when it is already set' do
      Timecop.freeze(Time.new(2015, 1, 1)) do
        token = UserToken.create!(token: 'token', expires_at: Time.new)
        expect(token.expires_at).to eq Time.new
      end
    end
  end


  describe '#prolong' do
    it 'should prolong token expiration time' do
      token = UserToken.create!(token: 'token', expires_at: Time.new(2015, 1, 1))
      Timecop.freeze(Time.new(2016, 1, 1)) do
        token.prolong
        token.save
        expect(token.expires_at).to eq (Time.new(2016, 1, 1) + UserToken::LIFETIME_DAYS.days)
      end
    end
  end


  describe '.with_token' do
    it 'finds objects with token' do
      token = UserToken.create!(token: 'token')
      expect(UserToken.with_token('token').first).to eq token

      expect(UserToken.with_token('wrong').first).to be_nil
    end
  end

  describe '.not_expired' do
    it 'finds objects with token which is not expired' do
      token = UserToken.create!(token: 'token', expires_at: Time.new(2015, 2, 10))

      Timecop.freeze(Time.new(2015, 1, 1)) do
        expect(UserToken.not_expired.first).to eq token
      end
    end

    it 'does not find objects with token which is not expired' do
      UserToken.create!(token: 'token', expires_at: Time.new(2015, 2, 10))

      Timecop.freeze(Time.new(2015, 2, 11)) do
        expect(UserToken.not_expired.first).to be_nil
      end
    end
  end


  describe '.delete_expired' do
    it 'deletes all the expired tokens' do
      UserToken.create!(token: 'token1', expires_at: Time.new(2015, 1, 1))
      UserToken.create!(token: 'token2', expires_at: Time.new(2015, 1, 11))
      token3 = UserToken.create!(token: 'token3', expires_at: Time.new(2015, 1, 21))
      token4 = UserToken.create!(token: 'token4', expires_at: Time.new(2015, 1, 31))

      Timecop.freeze(Time.new(2015, 1, 15)) do
        expect { UserToken.delete_expired }.to change { UserToken.count }.by(-2)
        expect(UserToken.all[0]).to eq token3
        expect(UserToken.all[1]).to eq token4
      end
    end
  end
end
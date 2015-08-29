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


  describe '#upcoming_critical_period' do
    let(:user) { FactoryGirl.create(:user) }

    let!(:future_periods) do
      [user.future_critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2)),
       user.future_critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1)),
       user.future_critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))]
    end

    it 'should return closest critical period after received date' do
      result = user.upcoming_critical_period(Date.new(2015, 2, 10))
      expect(result).to eq future_periods[1]
    end

    it 'should not return critical period if it started' do
      result = user.upcoming_critical_period(Date.new(2015, 2, 28))
      expect(result).to eq future_periods[2]
    end

    it 'should return null if there are no incoming periods' do
      result = user.upcoming_critical_period(Date.new(2016, 1, 6))
      expect(result).to be_nil
    end
  end
end
require 'rails_helper'

describe ResetPasswordMailer, type: :mailer do
  it 'sends mail' do
    user = FactoryGirl.create(:user, {reset_password_token: '12345'})
    expect { ResetPasswordMailer.send_reset_link(user).deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'raises exception when user has no token' do
    user = FactoryGirl.create(:user)
    expect { ResetPasswordMailer.send_reset_link(user).deliver_now }.to raise_error(ArgumentError)
  end
end

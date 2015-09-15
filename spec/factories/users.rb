FactoryGirl.define do
  # Classic user.
  factory :user do
    email 'example@email.com'
    password 'password'
    password_confirmation 'password'
  end

  # User with corrupted password (somehow).
  factory :corrupt_password_user, class: User do
    email 'example@email.com'
    encrypted_password 'corrupted'
  end
end
# Concern for model which provides password and password confirmation options.
# It will hash password and write it in encrypted password.
module PasswordsConcern
  extend ActiveSupport::Concern

  # Get password - it will return special hash object according to encrypted password.
  # This object is allowed to equal with actual password string.
  def password
    begin
      password = ::BCrypt::Password.new(self.encrypted_password)
    rescue
      password = nil
    end
    password
  end

  # Set password.
  # Password will be converted to special hash object.
  # This hash object also will be written into encrypted password.
  def password=(new_password)
    password = new_password.blank? ? nil : ::BCrypt::Password.create(new_password)
    self.encrypted_password = password
  end

  included do
    attr_accessor :password_confirmation
  end
end
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :encrypted_password, type: String

  has_many :critical_periods

  index({ email: 1 }, { unique: true })

  # Get password - it will return special hash object according to encrypted password.
  # This object is allowed to equal with actual password string.
  def password
    unless @password
      begin
        @password = ::BCrypt::Password.new(self.encrypted_password)
      rescue
        @password = nil
      end
    end
    @password
  end

  # Set password.
  # Password will be converted to special hash object.
  # This hash object also will be written into encrypted password.
  def password=(new_password)
    @password = ::BCrypt::Password.create(new_password)
    self.encrypted_password = @password
  end
end
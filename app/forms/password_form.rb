class PasswordForm
  include FormObject

  attr_reader :user
  attr_accessor :current_password, :new_password, :new_password_confirmation

  validate :validate_current_password
  validates :new_password, presence: true, confirmation: true

  def initialize(user, params = {})
    @user = user
    super(params)
  end

  def submit
    if valid?
      @user.password = new_password
      @user.password_confirmation = new_password_confirmation
      @user.save!
      true
    else
      false
    end
  end

  private

  def validate_current_password
    unless @user.password == current_password
      errors.add(:current_password, :wrong)
    end
  end
end
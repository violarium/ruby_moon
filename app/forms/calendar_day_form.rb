class CalendarDayForm
  include ActiveModel::Model

  attr_accessor :has_period

  def initialize(user, date, params = {})
    @user = user
    @date = date
    # todo: need to make it in another way
    super(params.slice(:has_period))
  end

  def submit
    if has_period
      @user.critical_periods.create(from: @date, to: @date)
    end
    # Validate date from and date to
    # validate period borders
    # add or update
  end
end
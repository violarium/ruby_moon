# Future critical period model.
# It is like a CriticalPeriod, but describes predicted period in future.
# Also it's less complicated.
#
# Belongs to user, have from and to field - Date types.
class FutureCriticalPeriod
  include UserPeriodConcern

  embeds_many :notifications, class_name: 'CriticalNotification', order: :time.asc

  scope :upcoming, -> (date) { order_by(:from => 'asc').where(:from.gt => date) }
end
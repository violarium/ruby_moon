# Notification for future critical period.
# It embedded in Future critical period.
#
# Have time field - time to notify about event.
class CriticalNotification
  include Mongoid::Document
  field :time, type: Time
  embedded_in :future_critical_period
end
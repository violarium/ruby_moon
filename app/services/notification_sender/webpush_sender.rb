class NotificationSender::WebpushSender
  include Rails.application.routes.url_helpers

  def initialize(vapid)
    @vapid = vapid
  end

  def send_notification(period)
    user = period.user
    I18n.with_locale(user.locale) do
      days_left = (period.from - user.today_date).to_i
      duration = (period.to - period.from).to_i

      message_title = I18n.t('webpush.periods.critical_period.subject', days_left: days_left, count: days_left)
      message_body = I18n.t('webpush.periods.critical_period.content.dates', start: period.from, end: period.to) +
          "\n" +
          I18n.t('webpush.periods.critical_period.content.duration', duration: duration, count: duration)

      message = {type: 'critical_period',
                 title: message_title, message: message_body,
                 link: calendar_path, link_title: I18n.t('webpush.periods.critical_period.open_link')}
      compiled_message = message.to_json

      user.user_web_subscriptions.all.each do |subscription|
        begin
          ::Webpush.payload_send message: compiled_message,
                                 endpoint: subscription.endpoint,
                                 p256dh: subscription.p256dh,
                                 auth: subscription.auth,
                                 vapid: @vapid
        rescue Webpush::InvalidSubscription
          subscription.delete
        rescue Webpush::ResponseError
          # do nothing
        end
      end
    end
  end
end
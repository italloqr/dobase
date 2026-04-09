# frozen_string_literal: true

class NotificationDigestMailer < ApplicationMailer
  def digest(user, notifications)
    @user = user
    @notifications = notifications

    mail(
      to: @user.email_address,
      subject: "#{notifications.size} new #{"notification".pluralize(notifications.size)} from #{Rails.application.config.x.app.name}"
    )
  end
end

# frozen_string_literal: true

class NominationsOpenNotificationJob < ApplicationJob
  queue_as :default

  def mailer
    unless @mailer.present?
      @mailer = NominationMailer.new
      @mailer.action_name = :nominations_notice_chicago
    end
    @mailer
  end

  def perform(user_id:)
    user = User.find_by(id: user_id)
    if user.present?
      puts "###> Sending a notification to #{user.email}:#{user.id} and related contacts"
      message = mailer.nominations_notice_chicago(user: user)

      message.deliver unless message.nil?
    end
  end
end

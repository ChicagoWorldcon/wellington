class NominationsOpenMassMailoutJob < ApplicationJob
  queue_as :default

  def perform(limit: nil)
    users = User.joins(reservations: :membership).where(memberships: { can_nominate: true }).distinct
    unless limit.nil?
      old_size = users.size
      users = users.slice(0, limit)
    end
    users.each do |user|
      NominationsOpenNotificationJob.perform_later(user_id: user.id)
    end
  end
end

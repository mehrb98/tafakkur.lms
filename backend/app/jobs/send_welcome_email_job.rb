# frozen_string_literal: true

class SendWelcomeEmailJob < ApplicationJob
    queue_as :mailers

    def perform(user_id)
        user = User.kept.find_by(id: user_id)
        return if user.nil? || !user.email_deliverable?

        UserMailer.welcome(user).deliver_now
    end
end

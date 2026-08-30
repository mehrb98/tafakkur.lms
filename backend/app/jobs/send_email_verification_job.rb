# frozen_string_literal: true

class SendEmailVerificationJob < ApplicationJob
    queue_as :mailers

    def perform(user_id, token)
        user = User.kept.find_by(id: user_id)
        return if user.nil?

        UserMailer.email_verification(user, token).deliver_now
    end
end

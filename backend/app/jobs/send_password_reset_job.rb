# frozen_string_literal: true

class SendPasswordResetJob < ApplicationJob
    queue_as :mailers

    def perform(user_id, token)
        user = User.kept.find_by(id: user_id)
        return if user.nil?

        UserMailer.password_reset(user, token).deliver_now
    end
end

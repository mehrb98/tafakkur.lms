# frozen_string_literal: true

class CleanupExpiredTokensJob < ApplicationJob
    queue_as :low

    def perform
        RefreshToken.where(expires_at: ...30.days.ago).delete_all
    end
end

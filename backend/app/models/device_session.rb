# frozen_string_literal: true

class DeviceSession < ApplicationRecord
    belongs_to :user
    belongs_to :refresh_token
    belongs_to :school

    validates :device_name, presence: true
    validates :last_active_at, presence: true
    validates :refresh_token_id, uniqueness: true

    scope :active, -> { joins(:refresh_token).merge(RefreshToken.active) }

    def touch_activity!
        update_column(:last_active_at, Time.current)
    end
end

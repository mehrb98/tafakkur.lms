# frozen_string_literal: true

class Subscription < ApplicationRecord
    belongs_to :school

    PLANS = %w[starter pro enterprise].freeze
    STATUSES = %w[active past_due cancelled].freeze

    validates :plan, inclusion: { in: PLANS }
    validates :status, inclusion: { in: STATUSES }
    validates :current_period_start, :current_period_end, presence: true
    validates :school_id, uniqueness: true
end

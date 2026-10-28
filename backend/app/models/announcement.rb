# frozen_string_literal: true

class Announcement < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :author, class_name: "User"

    TARGET_TYPES = %w[all role class section].freeze

    validates :title, presence: true, length: { maximum: 255 }
    validates :body, presence: true
    validates :target_type, inclusion: { in: TARGET_TYPES }

    scope :published, -> { where.not(published_at: nil) }

    def published?
        published_at.present?
    end

    def draft?
        published_at.nil?
    end
end

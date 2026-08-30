# frozen_string_literal: true

class AuditLog < ApplicationRecord
    belongs_to :school
    belongs_to :user, optional: true
    belongs_to :auditable, polymorphic: true, optional: true

    validates :action, presence: true

    def self.record!(user:, action:, school: nil, auditable: nil, metadata: {}, ip_address: nil)
        create!(
            school: school || user&.school || Current.school,
            user: user,
            action: action,
            auditable: auditable,
            metadata: metadata,
            ip_address: ip_address
        )
    end
end

# frozen_string_literal: true

class UserRole < ApplicationRecord
    include TenantScoped

    belongs_to :user
    belongs_to :role

    validates :role_id, uniqueness: { scope: :user_id }
end

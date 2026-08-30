# frozen_string_literal: true

# Custom-role schema placeholder (SAD §9). MVP authorization uses users.role;
# this table exists so future custom roles need no schema migration.
class Role < ApplicationRecord
    include TenantScoped

    has_many :user_roles, dependent: :destroy
    has_many :users, through: :user_roles

    validates :name, presence: true, uniqueness: { scope: :school_id }
end

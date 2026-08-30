# frozen_string_literal: true

class Parent < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :user
    has_many :parent_students, dependent: :destroy
    has_many :students, through: :parent_students

    validates :user_id, uniqueness: true
end

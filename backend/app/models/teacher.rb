# frozen_string_literal: true

class Teacher < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :user
    belongs_to :department, optional: true
    has_many :subject_assignments, dependent: :destroy
    has_many :sections, through: :subject_assignments
    has_many :homeroom_sections, class_name: "Section", foreign_key: :homeroom_teacher_id,
                                 inverse_of: :homeroom_teacher, dependent: :nullify

    validates :employee_code, presence: true, uniqueness: { scope: :school_id }
    validates :user_id, uniqueness: true

    scope :search, lambda { |query|
        joins(:user).where(
            "(users.first_name || ' ' || users.last_name) % :q " \
            "OR users.email ILIKE :like OR teachers.employee_code ILIKE :like",
            q: query, like: "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
        )
    }
end

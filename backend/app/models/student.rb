# frozen_string_literal: true

class Student < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :user
    has_many :enrollments, dependent: :destroy
    has_many :sections, through: :enrollments
    has_many :parent_students, dependent: :destroy
    has_many :parents, through: :parent_students

    GENDERS = %w[male female other].freeze

    validates :student_code, presence: true, uniqueness: { scope: :school_id }
    validates :user_id, uniqueness: true
    validates :gender, inclusion: { in: GENDERS }, allow_nil: true

    scope :search, lambda { |query|
        joins(:user).where(
            "(users.first_name || ' ' || users.last_name) % :q " \
            "OR users.email ILIKE :like OR students.student_code ILIKE :like",
            q: query, like: "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
        )
    }

    # Students visible to a teacher: enrolled in sections where the teacher has
    # a subject assignment or is homeroom teacher.
    scope :in_teacher_sections, lambda { |teacher|
        section_ids = SubjectAssignment.where(teacher_id: teacher.id).select(:section_id)
        homeroom_ids = Section.where(homeroom_teacher_id: teacher.id).select(:id)

        joins(:enrollments)
            .where(enrollments: { status: "active" })
            .where(
                "enrollments.section_id IN (?) OR enrollments.section_id IN (?)",
                section_ids, homeroom_ids
            )
            .distinct
    }
end

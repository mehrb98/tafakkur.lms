# frozen_string_literal: true

class SchoolClass < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :academic_year
    belongs_to :department, optional: true
    has_many :sections, dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: %i[school_id academic_year_id] }
    validates :grade_level, numericality: { only_integer: true, in: 1..12 }, allow_nil: true
end

# frozen_string_literal: true

class Subject < ApplicationRecord
    include TenantScoped
    include Discardable

    belongs_to :department, optional: true
    has_many :subject_assignments, dependent: :destroy

    validates :name, presence: true
    validates :code, presence: true, uniqueness: { scope: :school_id }
end

# frozen_string_literal: true

class SubjectAssignment < ApplicationRecord
    include TenantScoped

    belongs_to :teacher
    belongs_to :subject
    belongs_to :section
    belongs_to :semester

    validates :teacher_id, uniqueness: { scope: %i[subject_id section_id semester_id] }
    validate :all_parts_in_same_school

    private

    def all_parts_in_same_school
        %i[teacher subject section semester].each do |assoc|
            record = public_send(assoc)
            next if record.nil? || record.school_id == school_id

            errors.add(:"#{assoc}_id", "must belong to the same school")
        end
    end
end

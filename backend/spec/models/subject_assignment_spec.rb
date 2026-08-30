# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectAssignment, type: :model do
    it "is valid with all parts in the same school" do
        expect(build(:subject_assignment)).to be_valid
    end

    it "rejects duplicate assignments" do
        existing = create(:subject_assignment)
        duplicate = build(:subject_assignment,
                          school: existing.school,
                          teacher: existing.teacher,
                          subject: existing.subject,
                          section: existing.section,
                          semester: existing.semester)

        expect(duplicate).not_to be_valid
    end

    it "rejects a teacher from another school" do
        assignment = build(:subject_assignment)
        assignment.teacher = create(:teacher)

        expect(assignment).not_to be_valid
        expect(assignment.errors[:teacher_id]).to include("must belong to the same school")
    end
end

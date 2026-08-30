# frozen_string_literal: true

require "rails_helper"

RSpec.describe Enrollment, type: :model do
    let(:school) { create(:school) }
    let(:klass) { create(:school_class, school: school) }
    let(:section) { create(:section, school_class: klass, capacity: 2) }

    it "enforces one active enrollment per student per academic year" do
        student = create(:student, school: school)
        create(:enrollment, student: student, section: section)

        other_section = create(:section, school_class: klass)
        duplicate = build(:enrollment, student: student, section: other_section)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:student_id]).to be_present
    end

    it "allows re-enrollment after withdrawal" do
        student = create(:student, school: school)
        first = create(:enrollment, student: student, section: section)
        first.update!(status: "withdrawn")

        second = build(:enrollment, student: student, section: section)
        expect(second).to be_valid
    end

    it "rejects enrollment beyond section capacity" do
        2.times do
            create(:enrollment, section: section, student: create(:student, school: school))
        end

        overflow = build(:enrollment, section: section, student: create(:student, school: school))

        expect(overflow).not_to be_valid
        expect(overflow.errors[:section_id]).to include("is at full capacity")
    end

    it "requires the section to belong to the given academic year" do
        student = create(:student, school: school)
        other_year_class = create(:school_class, school: school)
        mismatched = build(:enrollment, student: student, section: section,
                                        academic_year: other_year_class.academic_year)

        expect(mismatched).not_to be_valid
        expect(mismatched.errors[:section_id]).to include("does not belong to the given academic year")
    end
end

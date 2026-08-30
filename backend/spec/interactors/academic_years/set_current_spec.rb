# frozen_string_literal: true

require "rails_helper"

RSpec.describe AcademicYears::SetCurrent, type: :interactor do
    it "sets the given year current and unsets the previous one" do
        school = create(:school)
        old_current = create(:academic_year, school: school, is_current: true)
        new_year = create(:academic_year, school: school)

        described_class.call(academic_year: new_year)

        expect(new_year.reload.is_current).to be(true)
        expect(old_current.reload.is_current).to be(false)
    end

    it "does not affect other schools' current year" do
        other_current = create(:academic_year, is_current: true)
        new_year = create(:academic_year)

        described_class.call(academic_year: new_year)

        expect(other_current.reload.is_current).to be(true)
    end
end

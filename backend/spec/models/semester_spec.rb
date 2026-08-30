# frozen_string_literal: true

require "rails_helper"

RSpec.describe Semester, type: :model do
    it "must fall within its academic year" do
        year = create(:academic_year, start_date: Date.new(2026, 9, 1), end_date: Date.new(2027, 6, 30))
        semester = build(:semester, academic_year: year,
                                    start_date: Date.new(2026, 8, 1), end_date: Date.new(2026, 12, 20))

        expect(semester).not_to be_valid
        expect(semester.errors[:base]).to be_present
    end

    it "is valid inside the academic year window" do
        year = create(:academic_year, start_date: Date.new(2026, 9, 1), end_date: Date.new(2027, 6, 30))
        semester = build(:semester, academic_year: year,
                                    start_date: Date.new(2026, 9, 2), end_date: Date.new(2026, 12, 20))

        expect(semester).to be_valid
    end
end

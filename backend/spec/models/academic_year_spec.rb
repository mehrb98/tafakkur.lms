# frozen_string_literal: true

require "rails_helper"

RSpec.describe AcademicYear, type: :model do
    it { is_expected.to have_many(:semesters).dependent(:destroy) }

    it "requires end date after start date" do
        year = build(:academic_year, start_date: Date.new(2027, 1, 1), end_date: Date.new(2026, 1, 1))
        expect(year).not_to be_valid
        expect(year.errors[:end_date]).to be_present
    end

    it "enforces name uniqueness per school" do
        existing = create(:academic_year)
        duplicate = build(:academic_year, school: existing.school, name: existing.name)
        expect(duplicate).not_to be_valid
    end

    it "allows same name in another school" do
        existing = create(:academic_year)
        other = build(:academic_year, name: existing.name)
        expect(other).to be_valid
    end

    describe "tenant scoping" do
        it "scopes queries to Current.school" do
            mine = create(:academic_year)
            other = create(:academic_year)

            Current.school = mine.school
            expect(described_class.all).to contain_exactly(mine)
            expect(described_class.all).not_to include(other)
        end
    end
end

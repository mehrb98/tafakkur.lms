# frozen_string_literal: true

require "rails_helper"

RSpec.describe Grade, type: :model do
    it "is valid with value within bounds" do
        expect(build(:grade, value: 0)).to be_valid
        expect(build(:grade, value: 100, max_value: 100)).to be_valid
    end

    it "rejects value above max_value" do
        grade = build(:grade, value: 101, max_value: 100)
        expect(grade).not_to be_valid
        expect(grade.errors[:value]).to include("must be less than or equal to max value")
    end

    it "rejects negative values" do
        expect(build(:grade, value: -1)).not_to be_valid
    end

    it "rejects unknown grade types" do
        expect(build(:grade, grade_type: "bonus")).not_to be_valid
    end
end

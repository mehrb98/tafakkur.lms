# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendAttendanceAlertJob, type: :job do
    it "emails every linked parent for an absent record" do
        record = create(:attendance_record, status: "absent")
        parent_one = create(:parent, school: record.school)
        parent_two = create(:parent, school: record.school)
        create(:parent_student, parent: parent_one, student: record.student)
        create(:parent_student, parent: parent_two, student: record.student, relationship: "mother")

        expect { described_class.perform_now(record.id) }
            .to change(ActionMailer::Base.deliveries, :count).by(2)
    end

    it "does nothing for present records" do
        record = create(:attendance_record, status: "present")

        expect { described_class.perform_now(record.id) }
            .not_to change(ActionMailer::Base.deliveries, :count)
    end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendGradeNotificationJob, type: :job do
    it "emails the student and linked parents" do
        grade = create(:grade)
        parent = create(:parent, school: grade.school)
        create(:parent_student, parent: parent, student: grade.student)

        expect { described_class.perform_now(grade.id) }
            .to change(ActionMailer::Base.deliveries, :count).by(2)
    end

    it "skips undeliverable recipients" do
        grade = create(:grade)
        grade.student.user.update!(email_deliverable: false)

        expect { described_class.perform_now(grade.id) }
            .not_to change(ActionMailer::Base.deliveries, :count)
    end
end

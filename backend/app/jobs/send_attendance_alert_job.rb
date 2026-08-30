# frozen_string_literal: true

class SendAttendanceAlertJob < ApplicationJob
    queue_as :mailers

    def perform(attendance_record_id)
        record = AttendanceRecord.find_by(id: attendance_record_id)
        return if record.nil? || !record.absent?

        record.student.parents.kept.includes(:user).find_each do |parent|
            next unless parent.user.email_deliverable?

            UserMailer.attendance_alert(parent.user, record).deliver_now
        end
    end
end

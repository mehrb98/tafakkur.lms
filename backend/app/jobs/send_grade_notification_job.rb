# frozen_string_literal: true

class SendGradeNotificationJob < ApplicationJob
    queue_as :mailers

    def perform(grade_id)
        grade = Grade.find_by(id: grade_id)
        return if grade.nil?

        recipients = [grade.student.user] + grade.student.parents.kept.includes(:user).map(&:user)
        recipients.select(&:email_deliverable?).each do |user|
            UserMailer.grade_notification(user, grade).deliver_now
        end
    end
end

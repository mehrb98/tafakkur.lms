# frozen_string_literal: true

class UserMailer < ApplicationMailer
    def welcome(user)
        @user = user
        @school = user.school
        mail(to: user.email, subject: "Welcome to #{@school.name}")
    end

    def password_reset(user, token)
        @user = user
        @reset_url = "#{frontend_url}/auth/reset-password/#{token}"
        mail(to: user.email, subject: "Reset your password")
    end

    def email_verification(user, token)
        @user = user
        @verify_url = "#{frontend_url}/auth/verify-email/#{token}"

        mail(to: user.email, subject: "Verify your email address")
    end

    def attendance_alert(parent_user, attendance_record)
        @parent_user = parent_user
        @record = attendance_record
        @student = attendance_record.student
        mail(to: parent_user.email,
             subject: "Absence notification: #{@student.user.full_name} on #{@record.date}")
    end

    def grade_notification(recipient, grade)
        @recipient = recipient
        @grade = grade
        @student = grade.student
        mail(to: recipient.email,
             subject: "New grade for #{@student.user.full_name}: #{grade.subject.name}")
    end

    private

    def frontend_url
        ENV.fetch("FRONTEND_URL", "http://localhost:3000")
    end
end

# frozen_string_literal: true

module Grades
    class Create
        include Interactor

        delegate :attributes, :teacher, to: :context

        def call
            grade = Grade.new(attributes.merge(teacher: teacher))

            unless grade.save
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: grade.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                )
            end

            SendGradeNotificationJob.perform_later(grade.id)
            AuditLog.record!(user: Current.user, action: "grade_created", auditable: grade)
            context.grade = grade
        end
    end
end

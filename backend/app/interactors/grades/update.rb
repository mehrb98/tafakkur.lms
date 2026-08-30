# frozen_string_literal: true

module Grades
    class Update
        include Interactor

        delegate :grade, :attributes, to: :context

        def call
            unless grade.update(attributes)
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: grade.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                )
            end

            SendGradeNotificationJob.perform_later(grade.id) if grade.saved_change_to_value?
            AuditLog.record!(user: Current.user, action: "grade_updated", auditable: grade)
        end
    end
end

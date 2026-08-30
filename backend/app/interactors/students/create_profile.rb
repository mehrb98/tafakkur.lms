# frozen_string_literal: true

module Students
    class CreateProfile
        include Interactor

        delegate :user, :profile_attributes, to: :context

        def call
            student = Student.new(profile_attributes.merge(user: user))

            unless student.save
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: student.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                )
            end

            AuditLog.record!(user: Current.user, action: "student_created", auditable: student)
            context.student = student
        end
    end
end

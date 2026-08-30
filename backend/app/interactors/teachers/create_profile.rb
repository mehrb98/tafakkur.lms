# frozen_string_literal: true

module Teachers
    class CreateProfile
        include Interactor

        delegate :user, :profile_attributes, to: :context

        def call
            teacher = Teacher.new(profile_attributes.merge(user: user))

            unless teacher.save
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: teacher.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                )
            end

            AuditLog.record!(user: Current.user, action: "teacher_created", auditable: teacher)
            context.teacher = teacher
        end
    end
end

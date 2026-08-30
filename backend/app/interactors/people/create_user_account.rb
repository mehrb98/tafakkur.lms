# frozen_string_literal: true

module People
    # Shared step: creates the User record for a person profile
    # (teacher/student/parent) and queues the welcome email.
    class CreateUserAccount
        include Interactor

        delegate :user_attributes, :role, to: :context

        def call
            user = User.new(user_attributes.merge(role: role, school_id: Current.school&.id))
            user.password ||= SecureRandom.base58(16)
            user.skip_confirmation_notification!

            unless user.save
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: user.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                )
            end

            SendWelcomeEmailJob.perform_later(user.id)
            context.user = user
        end

        def rollback
            context.user&.destroy
        end
    end
end

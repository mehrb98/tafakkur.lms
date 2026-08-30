# frozen_string_literal: true

module Parents
    class CreateProfile
        include Interactor

        delegate :user, :profile_attributes, to: :context

        def call
            parent = Parent.new((profile_attributes || {}).merge(user: user))

            unless parent.save
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: parent.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                )
            end

            AuditLog.record!(user: Current.user, action: "parent_created", auditable: parent)
            context.parent = parent
        end
    end
end

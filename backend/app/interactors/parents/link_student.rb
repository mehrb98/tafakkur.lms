# frozen_string_literal: true

module Parents
    class LinkStudent
        include Interactor

        delegate :parent, :student_id, :relationship, to: :context

        def call
            student = Student.kept.find_by(id: student_id)
            context.fail!(error_code: "not_found", error_message: "Record not found") if student.nil?

            link = ParentStudent.new(parent: parent, student: student, relationship: relationship)

            unless link.save
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: link.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                )
            end

            AuditLog.record!(user: Current.user, action: "parent_student_linked", auditable: link)
            context.link = link
        end
    end
end

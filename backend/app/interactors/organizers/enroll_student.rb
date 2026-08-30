# frozen_string_literal: true

module Organizers
    # Enrolls an existing student into a section, wrapped in a transaction so
    # a failed enrollment never leaves partial state.
    class EnrollStudent
        include Interactor

        delegate :student, :section_id, :enrolled_on, to: :context

        def call
            section = Section.kept.find_by(id: section_id)
            context.fail!(error_code: "not_found", error_message: "Record not found") if section.nil?

            enrollment = Enrollment.new(
                student: student,
                section: section,
                academic_year_id: section.school_class.academic_year_id,
                enrolled_on: enrolled_on || Date.current,
                status: "active"
            )

            unless enrollment.save
                context.fail!(
                    error_code: "validation_error",
                    error_message: "Record could not be saved",
                    error_details: enrollment.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                )
            end

            AuditLog.record!(user: Current.user, action: "student_enrolled", auditable: enrollment)
            context.enrollment = enrollment
        end
    end
end

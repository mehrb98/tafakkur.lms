# frozen_string_literal: true

module Organizers
    # Bulk-records attendance for a section on a date. Upserts row by row so
    # model validations run, all inside one transaction; absent students get an
    # alert email to their linked parents.
    class RecordAttendance
        include Interactor

        delegate :section, :date, :entries, :recorded_by, to: :context

        def call
            validate_entries!

            records = ActiveRecord::Base.transaction { upsert_all_entries }

            enqueue_absent_alerts(records)
            AuditLog.record!(
                user: recorded_by,
                action: "attendance_recorded",
                auditable: section,
                metadata: { date: date.to_s, count: records.size }
            )

            context.records = records
            context.summary = summarize(records)
        end

        private

        def validate_entries!
            context.fail!(error_code: "validation_error", error_message: "entries must not be empty") if entries.blank?

            enrolled_ids = section.enrollments.active.pluck(:student_id).to_set
            unknown = entries.map { |e| e[:student_id] }.reject { |id| enrolled_ids.include?(id) }
            return if unknown.empty?

            context.fail!(
                error_code: "validation_error",
                error_message: "Some students are not enrolled in this section",
                error_details: unknown.map { |id| { field: "student_id", message: "#{id} not enrolled" } }
            )
        end

        def upsert_all_entries
            entries.map do |entry|
                record = AttendanceRecord.find_or_initialize_by(
                    student_id: entry[:student_id],
                    section_id: section.id,
                    date: date
                )
                record.assign_attributes(
                    status: entry[:status],
                    note: entry[:note],
                    recorded_by: recorded_by,
                    school_id: section.school_id
                )
                unless record.save
                    context.fail!(
                        error_code: "validation_error",
                        error_message: "Record could not be saved",
                        error_details: record.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
                    )
                end
                record
            end
        end

        def enqueue_absent_alerts(records)
            records.select(&:absent?).each do |record|
                SendAttendanceAlertJob.perform_later(record.id)
            end
        end

        def summarize(records)
            records.group_by(&:status).transform_values(&:count)
        end
    end
end

# frozen_string_literal: true

module Api
    module V1
        class AttendanceRecordsController < BaseController
            def index
                scope = policy_scope(AttendanceRecord)
                scope = scope.for_section(params[:section_id]) if params[:section_id]
                scope = scope.where(student_id: params[:student_id]) if params[:student_id]
                scope = scope.on_date(params[:date]) if params[:date]
                scope = scope.where(date: params[:from]..params[:to]) if params[:from] && params[:to]
                @attendance_records = paginate(scope.order(date: :desc))
                render :index
            end

            def bulk
                section = Section.kept.find(params.require(:section_id))
                authorize section, :bulk?, policy_class: AttendanceRecordPolicy

                result = Organizers::RecordAttendance.call(
                    section: section,
                    date: Date.parse(params.require(:date)),
                    entries: bulk_entries,
                    recorded_by: current_user
                )
                return render_interactor_error(result) if result.failure?

                @records = result.records
                @summary = result.summary
                render :bulk, status: :created
            rescue Date::Error
                render_error(code: "bad_request", message: "Invalid date format", status: :bad_request)
            end

            def update
                @attendance_record = policy_scope(AttendanceRecord).find(params.expect(:id))
                authorize @attendance_record

                if @attendance_record.update(update_params.merge(recorded_by: current_user))
                    render :show
                else
                    render_validation_errors(@attendance_record.errors)
                end
            end

            private

            def bulk_entries
                params.require(:entries).map do |entry|
                    entry.permit(:student_id, :status, :note).to_h.symbolize_keys
                end
            end

            def update_params
                params.expect(attendance_record: %i[status note])
            end
        end
    end
end

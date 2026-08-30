# frozen_string_literal: true

json.data @attendance_records,
          partial: "api/v1/attendance_records/attendance_record",
          as: :attendance_record
json.partial! "api/v1/shared/meta", paginated: @attendance_records

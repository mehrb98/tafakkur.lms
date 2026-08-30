# frozen_string_literal: true

json.data do
    json.partial! "api/v1/attendance_records/attendance_record", attendance_record: @attendance_record
end

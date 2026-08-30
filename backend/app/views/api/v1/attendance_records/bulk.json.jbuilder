# frozen_string_literal: true

json.data do
    json.records @records,
                 partial: "api/v1/attendance_records/attendance_record",
                 as: :attendance_record
    json.summary @summary
end

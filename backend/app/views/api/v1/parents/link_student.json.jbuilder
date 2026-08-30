# frozen_string_literal: true

json.data do
    json.id @link.id
    json.parent_id @link.parent_id
    json.student_id @link.student_id
    json.relationship @link.relationship
end

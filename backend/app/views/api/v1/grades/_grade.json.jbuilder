# frozen_string_literal: true

json.id grade.id
json.student_id grade.student_id
json.subject_id grade.subject_id
json.semester_id grade.semester_id
json.teacher_id grade.teacher_id
json.grade_type grade.grade_type
json.value grade.value.to_f
json.max_value grade.max_value.to_f
json.comment grade.comment
json.graded_on grade.graded_on

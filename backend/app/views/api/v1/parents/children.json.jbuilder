# frozen_string_literal: true

json.data @students, partial: "api/v1/students/student", as: :student

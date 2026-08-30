class CreateGrades < ActiveRecord::Migration[8.1]
    def change
        create_table :grades, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :student, type: :uuid, null: false, foreign_key: true, index: false
            t.references :subject, type: :uuid, null: false, foreign_key: true
            t.references :semester, type: :uuid, null: false, foreign_key: true
            t.references :teacher, type: :uuid, null: false, foreign_key: true
            t.string :grade_type, limit: 32, null: false
            t.decimal :value, precision: 6, scale: 2, null: false
            t.decimal :max_value, precision: 6, scale: 2, null: false, default: 100
            t.text :comment
            t.date :graded_on, null: false

            t.timestamps
        end

        add_index :grades, %i[school_id student_id semester_id]
        add_index :grades, %i[student_id subject_id semester_id]
        add_index :grades, %i[school_id teacher_id graded_on]

        add_check_constraint :grades, "value >= 0 AND value <= max_value", name: "grades_value_within_bounds"
    end
end

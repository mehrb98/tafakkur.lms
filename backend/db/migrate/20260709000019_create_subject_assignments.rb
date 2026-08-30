class CreateSubjectAssignments < ActiveRecord::Migration[8.1]
    def change
        create_table :subject_assignments, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :teacher, type: :uuid, null: false, foreign_key: true
            t.references :subject, type: :uuid, null: false, foreign_key: true
            t.references :section, type: :uuid, null: false, foreign_key: true
            t.references :semester, type: :uuid, null: false, foreign_key: true

            t.timestamps
        end

        add_index :subject_assignments, %i[teacher_id subject_id section_id semester_id],
                  unique: true, name: "index_subject_assignments_uniqueness"
        add_index :subject_assignments, %i[school_id teacher_id]
    end
end

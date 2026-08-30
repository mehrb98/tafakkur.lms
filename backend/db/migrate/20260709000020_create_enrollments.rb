class CreateEnrollments < ActiveRecord::Migration[8.1]
    def change
        create_table :enrollments, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :student, type: :uuid, null: false, foreign_key: true, index: false
            t.references :section, type: :uuid, null: false, foreign_key: true
            t.references :academic_year, type: :uuid, null: false, foreign_key: true
            t.string :status, limit: 32, null: false, default: "active"
            t.date :enrolled_on, null: false

            t.timestamps
        end

        # One class per student per academic year (SAD database-schema §5.8).
        add_index :enrollments, %i[student_id academic_year_id], unique: true,
                                                                 where: "status = 'active'",
                                                                 name: "index_enrollments_one_active_per_year"
        add_index :enrollments, %i[school_id section_id status]
        add_index :enrollments, %i[student_id status]
    end
end

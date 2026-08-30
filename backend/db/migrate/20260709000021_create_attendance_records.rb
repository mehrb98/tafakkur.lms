class CreateAttendanceRecords < ActiveRecord::Migration[8.1]
    def change
        create_table :attendance_records, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :student, type: :uuid, null: false, foreign_key: true, index: false
            t.references :section, type: :uuid, null: false, foreign_key: true, index: false
            t.references :recorded_by, type: :uuid, null: false, foreign_key: { to_table: :users }
            t.date :date, null: false
            t.string :status, limit: 16, null: false
            t.text :note

            t.timestamps
        end

        add_index :attendance_records, %i[student_id section_id date], unique: true,
                                                                       name: "index_attendance_uniqueness"
        add_index :attendance_records, %i[school_id section_id date]
        add_index :attendance_records, %i[school_id student_id date]
    end
end

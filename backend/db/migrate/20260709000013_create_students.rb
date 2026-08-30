class CreateStudents < ActiveRecord::Migration[8.1]
    def change
        create_table :students, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }
            t.string :student_code, limit: 32, null: false
            t.date :date_of_birth
            t.string :gender, limit: 16
            t.text :address
            t.date :admission_date
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :students, %i[school_id student_code], unique: true
        add_index :students, :school_id, where: "discarded_at IS NULL", name: "index_students_on_school_id_kept"
        add_index :students, :student_code, using: :gin, opclass: :gin_trgm_ops,
                                            name: "index_students_on_student_code_trgm"
    end
end

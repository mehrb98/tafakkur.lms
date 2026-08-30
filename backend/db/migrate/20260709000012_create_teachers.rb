class CreateTeachers < ActiveRecord::Migration[8.1]
    def change
        create_table :teachers, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }
            t.references :department, type: :uuid, foreign_key: true
            t.string :employee_code, limit: 32, null: false
            t.string :specialization, limit: 150
            t.date :hire_date
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :teachers, %i[school_id employee_code], unique: true
        add_index :teachers, :school_id, where: "discarded_at IS NULL", name: "index_teachers_on_school_id_kept"
    end
end

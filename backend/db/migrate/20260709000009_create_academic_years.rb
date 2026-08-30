class CreateAcademicYears < ActiveRecord::Migration[8.1]
    def change
        create_table :academic_years, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.string :name, limit: 100, null: false
            t.date :start_date, null: false
            t.date :end_date, null: false
            t.boolean :is_current, null: false, default: false
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :academic_years, %i[school_id name], unique: true
        add_index :academic_years, :school_id, unique: true, where: "is_current = TRUE",
                                               name: "index_academic_years_one_current_per_school"
    end
end

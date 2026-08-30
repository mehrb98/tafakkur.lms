class CreateSemesters < ActiveRecord::Migration[8.1]
    def change
        create_table :semesters, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :academic_year, type: :uuid, null: false, foreign_key: true
            t.string :name, limit: 100, null: false
            t.date :start_date, null: false
            t.date :end_date, null: false
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :semesters, %i[school_id academic_year_id]
        add_index :semesters, %i[academic_year_id name], unique: true
    end
end

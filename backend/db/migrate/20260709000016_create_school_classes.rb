class CreateSchoolClasses < ActiveRecord::Migration[8.1]
    def change
        create_table :school_classes, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :academic_year, type: :uuid, null: false, foreign_key: true
            t.references :department, type: :uuid, foreign_key: true
            t.string :name, limit: 100, null: false
            t.integer :grade_level
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :school_classes, %i[school_id academic_year_id name], unique: true
    end
end

class CreateSubjects < ActiveRecord::Migration[8.1]
    def change
        create_table :subjects, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :department, type: :uuid, foreign_key: true
            t.string :name, limit: 150, null: false
            t.string :code, limit: 32, null: false
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :subjects, %i[school_id code], unique: true
        add_index :subjects, %i[school_id name]
    end
end

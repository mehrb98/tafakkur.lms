class CreateParents < ActiveRecord::Migration[8.1]
    def change
        create_table :parents, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }
            t.string :occupation, limit: 150
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :parents, :school_id, where: "discarded_at IS NULL", name: "index_parents_on_school_id_kept"

        create_table :parent_students, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true
            t.references :parent, type: :uuid, null: false, foreign_key: true, index: false
            t.references :student, type: :uuid, null: false, foreign_key: true
            t.string :relationship, limit: 32, null: false

            t.timestamps
        end

        add_index :parent_students, %i[parent_id student_id], unique: true
    end
end

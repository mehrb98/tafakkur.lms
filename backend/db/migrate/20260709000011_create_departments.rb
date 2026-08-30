class CreateDepartments < ActiveRecord::Migration[8.1]
    def change
        create_table :departments, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :parent, type: :uuid, foreign_key: { to_table: :departments }
            t.string :name, limit: 150, null: false
            t.text :description
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :departments, %i[school_id name], unique: true
    end
end

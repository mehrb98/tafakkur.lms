class CreateSections < ActiveRecord::Migration[8.1]
    def change
        create_table :sections, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :school_class, type: :uuid, null: false, foreign_key: true
            t.references :homeroom_teacher, type: :uuid, foreign_key: { to_table: :teachers }
            t.string :name, limit: 50, null: false
            t.integer :capacity, null: false, default: 30
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :sections, %i[school_class_id name], unique: true
        add_index :sections, %i[school_id school_class_id]
    end
end

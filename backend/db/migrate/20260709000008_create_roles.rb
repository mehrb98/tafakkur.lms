class CreateRoles < ActiveRecord::Migration[8.1]
    def change
        create_table :roles, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.string :name, limit: 64, null: false
            t.string :system_role, limit: 32
            t.jsonb :permissions, null: false, default: {}

            t.timestamps
        end

        add_index :roles, %i[school_id name], unique: true

        create_table :user_roles, id: :uuid do |t|
            t.references :user, type: :uuid, null: false, foreign_key: true, index: false
            t.references :role, type: :uuid, null: false, foreign_key: true
            t.references :school, type: :uuid, null: false, foreign_key: true

            t.timestamps
        end

        add_index :user_roles, %i[user_id role_id], unique: true
    end
end

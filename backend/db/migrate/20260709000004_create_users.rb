class CreateUsers < ActiveRecord::Migration[8.1]
    def change
        create_table :users, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.string :email, limit: 255, null: false
            t.string :encrypted_password, limit: 255, null: false
            t.string :role, limit: 32, null: false
            t.string :first_name, limit: 100, null: false
            t.string :last_name, limit: 100, null: false
            t.string :phone, limit: 32
            t.string :avatar_url, limit: 512
            t.boolean :email_deliverable, null: false, default: true

            ## Devise recoverable
            t.string :reset_password_token
            t.datetime :reset_password_sent_at

            ## Devise confirmable (email verification)
            t.string :confirmation_token
            t.datetime :confirmed_at
            t.datetime :confirmation_sent_at

            ## Devise trackable
            t.integer :sign_in_count, null: false, default: 0
            t.datetime :current_sign_in_at
            t.datetime :last_sign_in_at
            t.inet :current_sign_in_ip
            t.inet :last_sign_in_ip

            t.datetime :discarded_at

            t.timestamps
        end

        add_index :users, %i[school_id email], unique: true
        add_index :users, %i[school_id role]
        add_index :users, :school_id, where: "discarded_at IS NULL", name: "index_users_on_school_id_kept"
        add_index :users, :reset_password_token, unique: true
        add_index :users, :confirmation_token, unique: true
        add_index :users, :email, using: :gin, opclass: :gin_trgm_ops, name: "index_users_on_email_trgm"
    end
end

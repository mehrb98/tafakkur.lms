class CreateRefreshTokens < ActiveRecord::Migration[8.1]
    def change
        create_table :refresh_tokens, id: :uuid do |t|
            t.references :user, type: :uuid, null: false, foreign_key: true, index: false
            t.references :school, type: :uuid, null: false, foreign_key: true
            t.string :token_digest, limit: 255, null: false
            t.string :device_name, limit: 255
            t.inet :ip_address
            t.text :user_agent
            t.datetime :expires_at, null: false
            t.datetime :revoked_at
            t.references :replaced_by, type: :uuid, foreign_key: { to_table: :refresh_tokens }

            t.timestamps
        end

        add_index :refresh_tokens, :token_digest, unique: true
        add_index :refresh_tokens, %i[user_id revoked_at], where: "revoked_at IS NULL",
                                                           name: "index_refresh_tokens_active"
        add_index :refresh_tokens, :expires_at, where: "revoked_at IS NULL",
                                                name: "index_refresh_tokens_expiring"
    end
end

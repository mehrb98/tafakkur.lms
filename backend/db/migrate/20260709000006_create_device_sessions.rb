class CreateDeviceSessions < ActiveRecord::Migration[8.1]
    def change
        create_table :device_sessions, id: :uuid do |t|
            t.references :user, type: :uuid, null: false, foreign_key: true, index: false
            t.references :refresh_token, type: :uuid, null: false, foreign_key: true, index: { unique: true }
            t.references :school, type: :uuid, null: false, foreign_key: true
            t.string :device_name, limit: 255, null: false
            t.inet :ip_address
            t.datetime :last_active_at, null: false

            t.timestamps
        end

        add_index :device_sessions, %i[user_id last_active_at],
                  order: { last_active_at: :desc },
                  name: "index_device_sessions_on_user_activity"
    end
end

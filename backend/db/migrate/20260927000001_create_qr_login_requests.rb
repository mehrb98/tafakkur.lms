class CreateQrLoginRequests < ActiveRecord::Migration[8.1]
    def change
        create_table :qr_login_requests, id: :uuid do |t|
            # Shown in the QR code; the phone sends it to scan/approve.
            t.string :token_digest, limit: 255, null: false
            # Kept by the requesting browser only; required to collect the session.
            t.string :poll_secret_digest, limit: 255, null: false
            t.string :status, limit: 20, null: false, default: "pending"
            t.references :user, type: :uuid, foreign_key: true
            t.references :school, type: :uuid, foreign_key: true
            t.string :device_name, limit: 255
            t.inet :ip_address
            t.text :user_agent
            t.inet :approved_ip_address
            t.datetime :expires_at, null: false
            t.datetime :scanned_at
            t.datetime :approved_at
            t.datetime :consumed_at

            t.timestamps
        end

        add_index :qr_login_requests, :token_digest, unique: true
        add_index :qr_login_requests, :poll_secret_digest, unique: true
        add_index :qr_login_requests, :expires_at
    end
end

# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[8.1]
    def change
        create_table :reports, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :requested_by, type: :uuid, null: false, foreign_key: { to_table: :users }
            t.string :report_type, limit: 64, null: false
            t.jsonb :parameters, null: false, default: {}
            t.string :status, limit: 32, null: false, default: "pending"
            t.string :file_url, limit: 512
            t.text :error_message
            t.datetime :completed_at
            t.datetime :expires_at

            t.timestamps
        end

        add_index :reports, %i[school_id requested_by_id status]
        add_index :reports, :status, where: "status = 'pending'"
    end
end

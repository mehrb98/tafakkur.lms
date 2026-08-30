class CreateAuditLogs < ActiveRecord::Migration[8.1]
    def change
        create_table :audit_logs, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :user, type: :uuid, foreign_key: true, index: false
            t.string :action, limit: 64, null: false
            t.string :auditable_type, limit: 64
            t.uuid :auditable_id
            t.jsonb :metadata, null: false, default: {}
            t.inet :ip_address

            t.datetime :created_at, null: false
        end

        add_index :audit_logs, %i[school_id created_at], order: { created_at: :desc }
        add_index :audit_logs, %i[school_id user_id created_at],
                  order: { created_at: :desc },
                  name: "index_audit_logs_on_school_user_activity"
        add_index :audit_logs, %i[school_id auditable_type auditable_id],
                  name: "index_audit_logs_on_auditable"
    end
end

class CreateSubscriptions < ActiveRecord::Migration[8.1]
    def change
        create_table :subscriptions, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: { unique: true }
            t.string :plan, limit: 64, null: false, default: "starter"
            t.string :status, limit: 32, null: false, default: "active"
            t.datetime :current_period_start, null: false
            t.datetime :current_period_end, null: false
            t.jsonb :metadata, null: false, default: {}

            t.timestamps
        end

        add_index :subscriptions, %i[status current_period_end]
    end
end

class CreateSchools < ActiveRecord::Migration[8.1]
    def change
        create_table :schools, id: :uuid do |t|
            t.string :name, limit: 255, null: false
            t.string :slug, limit: 100, null: false
            t.string :domain, limit: 255
            t.string :timezone, limit: 64, null: false, default: "UTC"
            t.string :locale, limit: 10, null: false, default: "en"
            t.jsonb :settings, null: false, default: {}
            t.string :subscription_status, limit: 32, null: false, default: "trial"
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :schools, :slug, unique: true
        add_index :schools, :domain, unique: true, where: "domain IS NOT NULL"
        add_index :schools, :discarded_at, where: "discarded_at IS NULL"
    end
end

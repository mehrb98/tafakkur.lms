# frozen_string_literal: true

class CreateAnnouncements < ActiveRecord::Migration[8.1]
    def change
        create_table :announcements, id: :uuid do |t|
            t.references :school, type: :uuid, null: false, foreign_key: true, index: false
            t.references :author, type: :uuid, null: false, foreign_key: { to_table: :users }
            t.string :title, limit: 255, null: false
            t.text :body, null: false
            t.string :target_type, limit: 32, null: false, default: "all"
            t.jsonb :target_ids, null: false, default: []
            t.datetime :published_at
            t.datetime :discarded_at

            t.timestamps
        end

        add_index :announcements, %i[school_id published_at],
                  order: { published_at: :desc },
                  where: "published_at IS NOT NULL",
                  name: "index_announcements_on_school_published"
        add_index :announcements, %i[school_id target_type]
    end
end

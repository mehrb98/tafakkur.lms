class AddNameTrgmIndexToUsers < ActiveRecord::Migration[8.1]
    def up
        execute <<~SQL
            CREATE INDEX index_users_on_full_name_trgm
            ON users USING gin ((first_name || ' ' || last_name) gin_trgm_ops)
        SQL
    end

    def down
        execute "DROP INDEX IF EXISTS index_users_on_full_name_trgm"
    end
end

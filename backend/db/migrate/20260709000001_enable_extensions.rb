class EnableExtensions < ActiveRecord::Migration[8.1]
    def change
        enable_extension "pgcrypto"
        enable_extension "pg_trgm"
    end
end

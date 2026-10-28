# frozen_string_literal: true

module Lms
    module TasksSupport
        module_function

        def app_root
            if defined?(Rails) && Rails.respond_to?(:root)
                Rails.root
            else
                Pathname.new(File.expand_path("../..", __dir__))
            end
        end

        def compose_file
            app_root.join("../docker-compose.yml").expand_path
        end

        def compose_available?
            File.exist?(compose_file)
        end

        def load_dotenv!
            env_file = app_root.join(".env")
            return unless env_file.exist?

            env_file.readlines(chomp: true).each do |line|
                next if line.empty? || line.start_with?("#")

                key, value = line.split("=", 2)
                ENV[key] = value if key && value
            end
        end

        def copy_env_file!
            example = app_root.join(".env.example")
            target = app_root.join(".env")
            return if target.exist? || !example.exist?

            FileUtils.cp(example, target)
            puts "Created .env from .env.example"
        end

        def run!(*cmd)
            system(*cmd, exception: true)
        end

        def run(*cmd)
            system(*cmd)
        end

        def docker_compose(*args)
            run!("docker", "compose", "-f", compose_file.to_s, *args)
        end

        def docker_compose_app(*args)
            run!("docker", "compose", "-f", compose_file.to_s, "--profile", "app", *args)
        end

        def stop_app_containers!
            return unless compose_available?

            docker_compose_app("stop", "api", "sidekiq")
        end

        def start_app_containers!
            return unless compose_available?

            docker_compose_app("start", "api", "sidekiq")
        end

        # One-off API container (does not require the long-running api service).
        def docker_rails_run!(*rails_args, run_db_prepare: true)
            extra = run_db_prepare ? [] : ["-e", "RUN_DB_PREPARE=false"]
            docker_compose_app(
                "run", "--rm", "--no-deps", *extra,
                "api", "bundle", "exec", "rails", *rails_args
            )
        end

        def start_docker_services!
            return puts("docker-compose.yml not found — skipping Docker") unless compose_available?

            puts "Starting Docker services (db, redis)..."
            docker_compose("up", "-d", "db", "redis")
            puts "Waiting for services to become healthy..."
            sleep 5
        end

        def wait_for_postgres!
            host = ENV.fetch("DB_HOST", "localhost")
            port = ENV.fetch("DB_PORT", "5433")
            user = ENV.fetch("DB_USERNAME", "lms")

            30.times do
                return if run("pg_isready", "-h", host, "-p", port, "-U", user, out: File::NULL, err: File::NULL)

                sleep 1
            end

            warn "Postgres not ready on #{host}:#{port} — run `rails docker:up`"
        end

        def wait_for_redis!
            redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

            15.times do
                return if run("redis-cli", "-u", redis_url, "ping", out: File::NULL, err: File::NULL)

                sleep 1
            end

            warn "Redis not ready at #{redis_url} — run `rails docker:up`"
        end

        # Drop/reseed fails while Puma, Sidekiq, or db:prepare still hold connections.
        def disconnect_rails_database!
            return unless defined?(ActiveRecord::Base)

            ActiveRecord::Base.connection_handler.clear_all_connections!(:all)
        end

        def terminate_database_connections!
            return unless defined?(ActiveRecord::Base)

            dev_db = ActiveRecord::Base.connection_db_config.database
            test_db = ActiveRecord::Base.configurations.configs_for(env_name: "test").first&.database
            [dev_db, test_db].compact.uniq.each do |db_name|
                ActiveRecord::Base.connection.execute(
                    ActiveRecord::Base.sanitize_sql_array(
                        ["SELECT pg_terminate_backend(pid) FROM pg_stat_activity " \
                         "WHERE datname = ? AND pid <> pg_backend_pid()", db_name]
                    )
                )
            end
        end

        def print_dev_commands
            puts "\n== Ready =="
            puts "  rails dev            # API + Sidekiq (foreman)"
            puts "  rails server         # API only"
            puts "  rails db:seed        # demo data"
            puts "  rails spec           # RSpec"
            puts "  rails check          # quality gates"
        end
    end
end

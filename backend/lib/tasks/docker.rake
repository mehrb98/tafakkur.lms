# frozen_string_literal: true

require_relative "../lms/tasks_support"

namespace :docker do
    desc "Start Postgres (localhost:5433) and Redis (localhost:6379) — no API build"
    task :up do
        Lms::TasksSupport.start_docker_services!
        puts "Postgres → localhost:5433"
        puts "Redis    → localhost:6379"
        puts ""
        puts "Docker-only stack:  rails docker:start"
        puts "Local Rails on host: rails dev  (after bundle install)"
    end

    desc "Stop Docker services"
    task :down do
        Lms::TasksSupport.docker_compose("down", "--remove-orphans")
    end

    desc "Show running containers"
    task :ps do
        Lms::TasksSupport.docker_compose("ps", "-a")
    end

    desc "Tail Docker logs (SERVICE=api rails docker:logs)"
    task :logs do
        service = ENV.fetch("SERVICE", "api")
        Lms::TasksSupport.docker_compose_app("logs", "-f", *service.split)
    end

    desc "Build API image (gems installed inside Docker — nothing on host)"
    task :build do
        Lms::TasksSupport.docker_compose_app("build", "api")
        puts "Image tafakkur-lms:dev ready (gems baked in)"
    end

    desc "Build and run full stack in Docker (db, redis, api, sidekiq)"
    task :start do
        puts "Building API image (shared by api + sidekiq)..."
        Lms::TasksSupport.docker_compose_app("build", "api")
        puts "Starting full stack..."
        Lms::TasksSupport.docker_compose_app("up", "-d", "db", "redis", "api", "sidekiq")
        puts ""
        puts "API     → http://localhost:3001/api/v1"
        puts "Swagger → http://localhost:3001/api"
        puts "Health  → http://localhost:3001/health"
        puts "Logs    → rails docker:logs"
        puts "Seed    → rails 'docker:exec[db:seed]'"
    end

    desc "Open a shell inside the API container"
    task :shell do
        Lms::TasksSupport.docker_compose_app("exec", "api", "bash")
    end

    desc "Run Rails inside the API container — rails 'docker:exec[db:seed]' or DOCKER_EXEC=db:migrate rails docker:exec"
    task :exec, [:rails_command] => :environment do |_task, args|
        command = args.rails_command.presence || ENV["DOCKER_EXEC"].presence
        if command.blank?
            abort <<~MSG.strip
                Usage:
                  rails 'docker:exec[db:seed]'
                  rails 'docker:exec[db:migrate]'
                  rails 'docker:exec[db:reset]'
                  DOCKER_EXEC=db:migrate rails docker:exec

                (Plain `rails docker:exec db:seed` does not pass arguments to the task.)
            MSG
        end

        cmd = command.split
        Lms::TasksSupport.docker_compose_app("exec", "api", "bundle", "exec", "rails", *cmd)
    end

    desc "Reset DB in Docker — stops api+sidekiq first (avoids PG::ObjectInUse on drop)"
    task "db:reset" => :environment do
        puts "Stopping api and sidekiq so Postgres can drop lms_development..."
        puts "Also stop host `rails dev` if it is running (same database on :5433)."
        Lms::TasksSupport.stop_app_containers!
        sleep 2
        Lms::TasksSupport.terminate_database_connections!
        # This rake task loads :environment — disconnect so Postgres can drop the DB in Docker.
        Lms::TasksSupport.disconnect_rails_database!
        reset_ok = false
        begin
            Lms::TasksSupport.docker_rails_run!("db:reset", run_db_prepare: false)
            reset_ok = true
        ensure
            if reset_ok
                puts "Starting api and sidekiq..."
                Lms::TasksSupport.start_app_containers!
            else
                puts "Reset failed — api and sidekiq left stopped. Fix the error above, then: rails docker:start"
            end
        end
    end
end

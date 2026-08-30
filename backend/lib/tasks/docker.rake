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
        puts "Seed    → docker compose --profile app exec api bundle exec rails db:seed"
    end

    desc "Open a shell inside the API container"
    task :shell do
        Lms::TasksSupport.docker_compose_app("exec", "api", "bash")
    end

    desc "Run a Rails command inside the API container (e.g. rails docker:exec db:seed)"
    task :exec do
        cmd = ARGV[1..]
        abort "Usage: rails docker:exec db:seed" if cmd.empty?

        Lms::TasksSupport.docker_compose_app("exec", "api", "bundle", "exec", "rails", *cmd)
    end
end

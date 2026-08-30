# frozen_string_literal: true

require_relative "../lms/tasks_support"

namespace :setup do
    desc "Copy .env.example to .env if missing"
    task env: :environment do
        Lms::TasksSupport.copy_env_file!
        puts "Environment file ready"
    end

    desc "Prepare database (create + migrate)"
    task db: :environment do
        Lms::TasksSupport.load_dotenv!
        Rake::Task["setup:env"].invoke unless Rails.root.join(".env").exist?
        Lms::TasksSupport.wait_for_postgres!
        Rake::Task["db:prepare"].invoke
        puts "Database ready"
    end

    desc "Reset database (drop, create, migrate, seed)"
    task "db:reset": :environment do
        Rake::Task["db:reset"].invoke
        puts "Database reset complete"
    end
end

desc "Full project setup (Docker, gems, database)"
task setup: :environment do
    Lms::TasksSupport.copy_env_file!
    Lms::TasksSupport.load_dotenv!

    unless ENV["SKIP_DOCKER"]
        Lms::TasksSupport.start_docker_services!
        Lms::TasksSupport.wait_for_postgres!
        Lms::TasksSupport.wait_for_redis!
    end

    puts "\n== Installing dependencies =="
    Lms::TasksSupport.run("bundle check") || Lms::TasksSupport.run!("bundle install")

    Rake::Task["setup:db"].invoke

    puts "\n== Clearing logs and tmp =="
    Rake::Task["log:clear"].invoke
    Rake::Task["tmp:clear"].invoke

    Lms::TasksSupport.print_dev_commands
end

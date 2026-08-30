# frozen_string_literal: true

require_relative "../lms/tasks_support"

desc "Run RuboCop, Brakeman, bundler-audit, and RSpec"
task check: :environment do
    steps = [
        ["RuboCop", %w[bundle exec rubocop]],
        ["Brakeman", %w[bundle exec brakeman -q -w2]],
        ["Bundler Audit", %w[bundle exec bundler-audit check]],
        ["RSpec", %w[bundle exec rspec]]
    ]

    steps.each do |label, cmd|
        puts "\n== #{label} =="
        Lms::TasksSupport.run!(*cmd)
    end

    puts "\n== All checks passed =="
end

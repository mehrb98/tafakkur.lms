# frozen_string_literal: true

desc "Start API + Sidekiq via Procfile.dev (foreman)"
task dev: :environment do
    procfile = Rails.root.join("Procfile.dev")
    unless procfile.exist?
        abort "Procfile.dev not found"
    end

    exec "bundle", "exec", "foreman", "start", "-f", procfile.to_s
end

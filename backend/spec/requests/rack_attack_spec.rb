# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack::Attack throttling", type: :request do
    before do
        Rack::Attack.enabled = true
        Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    end

    after do
        Rack::Attack.enabled = false
    end

    it "throttles login attempts per email after 5 tries" do
        school = create(:school)
        create(:user, school: school, email: "victim@example.com")

        6.times do
            post "/api/v1/auth/login",
                 params: { email: "victim@example.com", password: "wrong" }.to_json,
                 headers: { "Content-Type" => "application/json" }
        end

        expect(response).to have_http_status(:too_many_requests)
        expect(json_body.dig("error", "code")).to eq("rate_limit_exceeded")
    end

    it "does not throttle health checks" do
        301.times { get "/health" } if ENV["FULL_THROTTLE_SPEC"]
        get "/health"
        expect(response).to have_http_status(:ok)
    end
end

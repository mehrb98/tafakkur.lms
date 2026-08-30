# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health endpoints", type: :request do
    describe "GET /health" do
        it "returns ok" do
            get "/health"

            expect(response).to have_http_status(:ok)
            expect(json_body["status"]).to eq("ok")
        end
    end

    describe "GET /health/ready" do
        it "reports database and redis status" do
            allow(Sidekiq).to receive(:redis).and_return("PONG")

            get "/health/ready"

            expect(response).to have_http_status(:ok)
            expect(json_body["checks"]).to include("database" => "ok", "redis" => "ok")
        end
    end
end

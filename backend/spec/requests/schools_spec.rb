# frozen_string_literal: true

require "rails_helper"

RSpec.describe "School management", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:teacher) { create(:user, :teacher, school: school) }

    describe "GET /api/v1/school" do
        it "returns the current school for any authenticated user" do
            get "/api/v1/school", headers: authenticated_headers(teacher)

            expect(response).to have_http_status(:ok)
            expect(json_body.dig("data", "id")).to eq(school.id)
        end

        it "returns 401 without a token" do
            get "/api/v1/school"
            expect(response).to have_http_status(:unauthorized)
        end
    end

    describe "PATCH /api/v1/school" do
        it "allows admin to update school details" do
            patch "/api/v1/school",
                  params: { school: { name: "Renamed School" } }.to_json,
                  headers: authenticated_headers(admin)

            expect(response).to have_http_status(:ok)
            expect(school.reload.name).to eq("Renamed School")
        end

        it "forbids non-admin roles" do
            patch "/api/v1/school",
                  params: { school: { name: "Nope" } }.to_json,
                  headers: authenticated_headers(teacher)

            expect(response).to have_http_status(:forbidden)
            expect(json_body.dig("error", "code")).to eq("forbidden")
        end
    end

    describe "settings endpoints" do
        it "allows admin to read and merge settings" do
            patch "/api/v1/settings",
                  params: { settings: { features: { messaging: true } } }.to_json,
                  headers: authenticated_headers(admin)

            expect(response).to have_http_status(:ok)
            expect(school.reload.settings.dig("features", "messaging")).to be(true)
        end

        it "forbids teachers from settings" do
            get "/api/v1/settings", headers: authenticated_headers(teacher)
            expect(response).to have_http_status(:forbidden)
        end
    end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Academic years", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:teacher) { create(:user, :teacher, school: school) }
    let!(:year) { create(:academic_year, school: school) }
    let(:other_school_year) { create(:academic_year) }

    describe "GET /api/v1/academic_years" do
        it "lists only the current school's years with pagination meta" do
            other_school_year

            get "/api/v1/academic_years", headers: authenticated_headers(teacher)

            expect(response).to have_http_status(:ok)
            ids = json_body["data"].pluck("id")
            expect(ids).to contain_exactly(year.id)
            expect(json_body["meta"]).to include("page", "total")
        end
    end

    describe "POST /api/v1/academic_years" do
        it "allows admin to create and mark current" do
            post "/api/v1/academic_years",
                 params: {
                     academic_year: {
                         name: "2027-2028",
                         start_date: "2027-09-01",
                         end_date: "2028-06-30",
                         is_current: true
                     }
                 }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "is_current")).to be(true)
        end

        it "forbids teachers" do
            post "/api/v1/academic_years",
                 params: { academic_year: { name: "X", start_date: "2027-09-01", end_date: "2028-06-30" } }.to_json,
                 headers: authenticated_headers(teacher)

            expect(response).to have_http_status(:forbidden)
        end

        it "returns the validation error envelope" do
            post "/api/v1/academic_years",
                 params: { academic_year: { name: "", start_date: "2027-09-01", end_date: "2026-06-30" } }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_body.dig("error", "code")).to eq("validation_error")
            expect(json_body.dig("error", "details")).to be_an(Array)
        end
    end

    describe "DELETE /api/v1/academic_years/:id" do
        it "soft deletes" do
            delete "/api/v1/academic_years/#{year.id}", headers: authenticated_headers(admin)

            expect(response).to have_http_status(:no_content)
            expect(year.reload.discarded_at).to be_present
        end
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/academic_years/#{other_school_year.id}" }
        let(:requesting_user) { admin }
    end
end

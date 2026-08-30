# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Semesters", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:year) { create(:academic_year, school: school) }
    let!(:semester) { create(:semester, academic_year: year) }

    describe "GET /api/v1/academic_years/:id/semesters" do
        it "lists semesters of the year" do
            get "/api/v1/academic_years/#{year.id}/semesters", headers: authenticated_headers(admin)

            expect(response).to have_http_status(:ok)
            expect(json_body["data"].pluck("id")).to contain_exactly(semester.id)
        end
    end

    describe "POST /api/v1/semesters" do
        it "creates a semester within the year" do
            post "/api/v1/semesters",
                 params: {
                     semester: {
                         academic_year_id: year.id,
                         name: "Spring",
                         start_date: year.start_date + 5.months,
                         end_date: year.start_date + 9.months
                     }
                 }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:created)
        end

        it "rejects a semester outside the year window" do
            post "/api/v1/semesters",
                 params: {
                     semester: {
                         academic_year_id: year.id,
                         name: "Bad",
                         start_date: year.start_date - 1.month,
                         end_date: year.start_date + 1.month
                     }
                 }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns 404 when the academic year belongs to another school" do
            other_year = create(:academic_year)

            post "/api/v1/semesters",
                 params: {
                     semester: {
                         academic_year_id: other_year.id,
                         name: "Cross",
                         start_date: other_year.start_date,
                         end_date: other_year.start_date + 2.months
                     }
                 }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:not_found)
        end
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/semesters/#{create(:semester).id}" }
        let(:requesting_user) { admin }
    end
end

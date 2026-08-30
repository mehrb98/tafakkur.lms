# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Departments", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:teacher) { create(:user, :teacher, school: school) }

    describe "CRUD" do
        it "creates, lists and nests departments" do
            post "/api/v1/departments",
                 params: { department: { name: "Sciences" } }.to_json,
                 headers: authenticated_headers(admin)
            expect(response).to have_http_status(:created)
            parent_id = json_body.dig("data", "id")

            post "/api/v1/departments",
                 params: { department: { name: "Physics", parent_id: parent_id } }.to_json,
                 headers: authenticated_headers(admin)
            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "parent_id")).to eq(parent_id)

            get "/api/v1/departments", headers: authenticated_headers(teacher)
            expect(json_body["data"].length).to eq(2)
        end

        it "rejects a parent from another school" do
            foreign_parent = create(:department)

            post "/api/v1/departments",
                 params: { department: { name: "Physics", parent_id: foreign_parent.id } }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/departments/#{create(:department).id}" }
        let(:requesting_user) { admin }
    end
end

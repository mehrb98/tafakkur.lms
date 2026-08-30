# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Parents", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }

    describe "POST /api/v1/parents" do
        it "creates user + parent profile" do
            post "/api/v1/parents",
                 params: {
                     parent: {
                         occupation: "Doctor",
                         user: { email: "parent@example.com", first_name: "Gulnora", last_name: "Yusupova" }
                     }
                 }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "occupation")).to eq("Doctor")
        end
    end

    describe "POST /api/v1/parents/:id/link_student" do
        let(:parent) { create(:parent, school: school) }

        it "links a student in the same school" do
            student = create(:student, school: school)

            post "/api/v1/parents/#{parent.id}/link_student",
                 params: { student_id: student.id, relationship: "mother" }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:created)
            expect(parent.students).to include(student)
        end

        it "returns 404 for a student from another school" do
            foreign_student = create(:student)

            post "/api/v1/parents/#{parent.id}/link_student",
                 params: { student_id: foreign_student.id, relationship: "mother" }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:not_found)
        end

        it "rejects duplicate links" do
            student = create(:student, school: school)
            create(:parent_student, parent: parent, student: student)

            post "/api/v1/parents/#{parent.id}/link_student",
                 params: { student_id: student.id, relationship: "father" }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe "GET /api/v1/parents/:id/children" do
        it "returns linked students for the parent themselves" do
            parent = create(:parent, school: school)
            student = create(:student, school: school)
            create(:parent_student, parent: parent, student: student)

            get "/api/v1/parents/#{parent.id}/children", headers: authenticated_headers(parent.user)

            expect(response).to have_http_status(:ok)
            expect(json_body["data"].pluck("id")).to contain_exactly(student.id)
        end

        it "forbids another parent from listing children" do
            parent = create(:parent, school: school)
            other_parent = create(:parent, school: school)

            get "/api/v1/parents/#{parent.id}/children", headers: authenticated_headers(other_parent.user)

            expect(response).to have_http_status(:not_found)
        end
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/parents/#{create(:parent).id}" }
        let(:requesting_user) { admin }
    end
end

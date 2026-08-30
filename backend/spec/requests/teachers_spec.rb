# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teachers", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:teacher_user) { create(:user, :teacher, school: school) }

    describe "POST /api/v1/teachers" do
        let(:payload) do
            {
                teacher: {
                    employee_code: "EMP9001",
                    specialization: "Physics",
                    user: {
                        email: "newteacher@example.com",
                        first_name: "Nodira",
                        last_name: "Karimova"
                    }
                }
            }
        end

        it "creates user + teacher profile and enqueues welcome email" do
            expect do
                post "/api/v1/teachers", params: payload.to_json, headers: authenticated_headers(admin)
            end.to change(Teacher, :count).by(1)
                                          .and change(User.where(role: "teacher"), :count).by(1)
                                                                                          .and have_enqueued_job(SendWelcomeEmailJob)

            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "employee_code")).to eq("EMP9001")
            expect(json_body.dig("data", "user", "email")).to eq("newteacher@example.com")
        end

        it "rolls back the user when the profile is invalid" do
            payload[:teacher][:employee_code] = ""
            headers = authenticated_headers(admin)

            expect do
                post "/api/v1/teachers", params: payload.to_json, headers: headers
            end.not_to change(User, :count)

            expect(response).to have_http_status(:unprocessable_entity)
        end

        it "forbids teachers from creating teachers" do
            post "/api/v1/teachers", params: payload.to_json, headers: authenticated_headers(teacher_user)
            expect(response).to have_http_status(:forbidden)
        end
    end

    describe "GET /api/v1/teachers" do
        it "supports trigram search by name" do
            target = create(:teacher, school: school,
                                      user: create(:user, :teacher, school: school,
                                                                    first_name: "Alisher", last_name: "Navoiy"))
            create(:teacher, school: school)

            get "/api/v1/teachers", params: { q: "Alisher" }, headers: authenticated_headers(admin)

            expect(response).to have_http_status(:ok)
            expect(json_body["data"].pluck("id")).to contain_exactly(target.id)
        end
    end

    describe "DELETE /api/v1/teachers/:id" do
        it "soft deletes teacher and user" do
            teacher = create(:teacher, school: school)

            delete "/api/v1/teachers/#{teacher.id}", headers: authenticated_headers(admin)

            expect(response).to have_http_status(:no_content)
            expect(teacher.reload.discarded_at).to be_present
            expect(teacher.user.reload.discarded_at).to be_present
        end
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/teachers/#{create(:teacher).id}" }
        let(:requesting_user) { admin }
    end
end

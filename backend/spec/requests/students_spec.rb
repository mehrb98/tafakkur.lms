# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Students", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }

    describe "POST /api/v1/students" do
        let(:payload) do
            {
                student: {
                    student_code: "STU9001",
                    gender: "male",
                    user: {
                        email: "student@example.com",
                        first_name: "Bobur",
                        last_name: "Aliyev"
                    }
                }
            }
        end

        it "creates user + student profile" do
            post "/api/v1/students", params: payload.to_json, headers: authenticated_headers(admin)

            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "student_code")).to eq("STU9001")
        end

        it "rejects duplicate student_code within the school" do
            create(:student, school: school, student_code: "STU9001")

            post "/api/v1/students", params: payload.to_json, headers: authenticated_headers(admin)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_body.dig("error", "details").first["field"]).to eq("student_code")
        end

        it "allows the same student_code in another school" do
            create(:student, student_code: "STU9001")

            post "/api/v1/students", params: payload.to_json, headers: authenticated_headers(admin)

            expect(response).to have_http_status(:created)
        end
    end

    describe "POST /api/v1/students/:id/enroll" do
        it "enrolls the student into a section" do
            student = create(:student, school: school)
            klass = create(:school_class, school: school)
            section = create(:section, school_class: klass)

            post "/api/v1/students/#{student.id}/enroll",
                 params: { section_id: section.id }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "status")).to eq("active")
            expect(student.enrollments.active.count).to eq(1)
        end
    end

    describe "role-based visibility" do
        let(:student_record) { create(:student, school: school) }

        it "lets a student see only their own record" do
            other = create(:student, school: school)

            get "/api/v1/students", headers: authenticated_headers(student_record.user)

            ids = json_body["data"].pluck("id")
            expect(ids).to contain_exactly(student_record.id)
            expect(ids).not_to include(other.id)
        end

        it "lets a parent see only linked children" do
            parent = create(:parent, school: school)
            create(:parent_student, parent: parent, student: student_record)
            create(:student, school: school)

            get "/api/v1/students", headers: authenticated_headers(parent.user)

            expect(json_body["data"].pluck("id")).to contain_exactly(student_record.id)
        end

        it "lets a teacher see only students in their sections" do
            teacher = create(:teacher, school: school)
            klass = create(:school_class, school: school)
            section = create(:section, school_class: klass, homeroom_teacher: teacher)
            enrolled = create(:student, school: school)
            create(:enrollment, student: enrolled, section: section)
            create(:student, school: school) # not in teacher's section

            get "/api/v1/students", headers: authenticated_headers(teacher.user)

            expect(json_body["data"].pluck("id")).to contain_exactly(enrolled.id)
        end
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/students/#{create(:student).id}" }
        let(:requesting_user) { admin }
    end
end

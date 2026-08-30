# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Grades", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:teacher) { create(:teacher, school: school) }
    let(:student) { create(:student, school: school) }
    let(:subject_record) { create(:subject, school: school) }
    let(:year) { create(:academic_year, school: school) }
    let(:semester) { create(:semester, academic_year: year) }
    let(:section) { create(:section, school_class: create(:school_class, school: school, academic_year: year)) }
    let(:payload) do
        {
            grade: {
                student_id: student.id,
                subject_id: subject_record.id,
                semester_id: semester.id,
                grade_type: "exam",
                value: 92,
                max_value: 100,
                graded_on: "2026-10-05"
            }
        }
    end

    before do
        create(:subject_assignment, school: school, teacher: teacher,
                                    subject: subject_record, section: section, semester: semester)
    end

    describe "POST /api/v1/grades" do
        it "lets an assigned teacher create a grade and notifies student + parents" do
            parent = create(:parent, school: school)
            create(:parent_student, parent: parent, student: student)

            expect do
                post "/api/v1/grades", params: payload.to_json, headers: authenticated_headers(teacher.user)
            end.to change(Grade, :count).by(1)
                                        .and have_enqueued_job(SendGradeNotificationJob)

            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "value")).to eq(92.0)
            expect(json_body.dig("data", "teacher_id")).to eq(teacher.id)
        end

        it "forbids a teacher without a matching subject assignment" do
            outsider = create(:teacher, school: school)

            post "/api/v1/grades", params: payload.to_json, headers: authenticated_headers(outsider.user)

            expect(response).to have_http_status(:forbidden)
        end

        it "lets admin create a grade on behalf of a teacher" do
            payload[:grade][:teacher_id] = teacher.id

            post "/api/v1/grades", params: payload.to_json, headers: authenticated_headers(admin)

            expect(response).to have_http_status(:created)
        end

        it "rejects out-of-bounds values with the error envelope" do
            payload[:grade][:value] = 150

            post "/api/v1/grades", params: payload.to_json, headers: authenticated_headers(teacher.user)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_body.dig("error", "code")).to eq("validation_error")
        end
    end

    describe "PATCH /api/v1/grades/:id" do
        let!(:grade) do
            create(:grade, school: school, student: student, subject: subject_record,
                           semester: semester, teacher: teacher)
        end

        it "lets the owning teacher update and re-notifies on value change" do
            expect do
                patch "/api/v1/grades/#{grade.id}",
                      params: { grade: { value: 95 } }.to_json,
                      headers: authenticated_headers(teacher.user)
            end.to have_enqueued_job(SendGradeNotificationJob)

            expect(response).to have_http_status(:ok)
            expect(grade.reload.value).to eq(95)
        end

        it "does not notify when only the comment changes" do
            expect do
                patch "/api/v1/grades/#{grade.id}",
                      params: { grade: { comment: "Good work" } }.to_json,
                      headers: authenticated_headers(teacher.user)
            end.not_to have_enqueued_job(SendGradeNotificationJob)
        end

        it "forbids another teacher from updating" do
            other_teacher = create(:teacher, school: school)

            patch "/api/v1/grades/#{grade.id}",
                  params: { grade: { value: 10 } }.to_json,
                  headers: authenticated_headers(other_teacher.user)

            expect(response).to have_http_status(:not_found)
        end
    end

    describe "DELETE /api/v1/grades/:id" do
        let!(:grade) do
            create(:grade, school: school, student: student, subject: subject_record,
                           semester: semester, teacher: teacher)
        end

        it "allows admin" do
            delete "/api/v1/grades/#{grade.id}", headers: authenticated_headers(admin)
            expect(response).to have_http_status(:no_content)
        end

        it "forbids the teacher" do
            delete "/api/v1/grades/#{grade.id}", headers: authenticated_headers(teacher.user)
            expect(response).to have_http_status(:forbidden)
        end
    end

    describe "GET /api/v1/grades" do
        let!(:grade) do
            create(:grade, school: school, student: student, subject: subject_record,
                           semester: semester, teacher: teacher)
        end

        it "lets a student see only their grades" do
            other_student = create(:student, school: school)
            create(:grade, school: school, student: other_student, subject: subject_record,
                           semester: semester, teacher: teacher)

            get "/api/v1/grades", headers: authenticated_headers(student.user)

            expect(json_body["data"].pluck("student_id").uniq).to eq([student.id])
        end

        it "lets a parent see only linked children's grades" do
            parent = create(:parent, school: school)
            create(:parent_student, parent: parent, student: student)

            get "/api/v1/grades", headers: authenticated_headers(parent.user)

            expect(json_body["data"].pluck("id")).to contain_exactly(grade.id)
        end
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/grades/#{create(:grade).id}" }
        let(:requesting_user) { admin }
    end
end

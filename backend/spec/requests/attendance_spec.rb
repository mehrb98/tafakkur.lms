# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attendance", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:teacher) { create(:teacher, school: school) }
    let(:klass) { create(:school_class, school: school) }
    let(:section) { create(:section, school_class: klass, homeroom_teacher: teacher) }
    let(:students) { create_list(:student, 3, school: school) }

    before do
        students.each { |s| create(:enrollment, student: s, section: section) }
    end

    describe "POST /api/v1/attendance_records/bulk" do
        let(:payload) do
            {
                section_id: section.id,
                date: "2026-09-15",
                entries: [
                    { student_id: students[0].id, status: "present" },
                    { student_id: students[1].id, status: "absent", note: "sick" },
                    { student_id: students[2].id, status: "late" }
                ]
            }
        end

        it "records attendance with a summary and enqueues absent alerts" do
            expect do
                post "/api/v1/attendance_records/bulk",
                     params: payload.to_json,
                     headers: authenticated_headers(teacher.user)
            end.to change(AttendanceRecord, :count).by(3)
                                                   .and have_enqueued_job(SendAttendanceAlertJob).exactly(:once)

            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "summary")).to eq("present" => 1, "absent" => 1, "late" => 1)
        end

        it "upserts on repeat submission instead of duplicating" do
            headers = authenticated_headers(teacher.user)
            post "/api/v1/attendance_records/bulk", params: payload.to_json, headers: headers

            payload[:entries][0][:status] = "absent"
            expect do
                post "/api/v1/attendance_records/bulk", params: payload.to_json, headers: headers
            end.not_to change(AttendanceRecord, :count)

            expect(response).to have_http_status(:created)
            record = AttendanceRecord.find_by(student_id: students[0].id, section_id: section.id)
            expect(record.status).to eq("absent")
        end

        it "rejects entries for students not enrolled in the section" do
            outsider = create(:student, school: school)
            payload[:entries] << { student_id: outsider.id, status: "present" }

            post "/api/v1/attendance_records/bulk",
                 params: payload.to_json,
                 headers: authenticated_headers(teacher.user)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_body.dig("error", "details")).to be_present
        end

        it "forbids a teacher who is not assigned to the section" do
            other_teacher = create(:teacher, school: school)

            post "/api/v1/attendance_records/bulk",
                 params: payload.to_json,
                 headers: authenticated_headers(other_teacher.user)

            expect(response).to have_http_status(:forbidden)
        end

        it "returns 404 for a section of another school" do
            foreign_section = create(:section)
            payload[:section_id] = foreign_section.id

            post "/api/v1/attendance_records/bulk",
                 params: payload.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:not_found)
        end
    end

    describe "GET /api/v1/attendance_records" do
        before do
            create(:attendance_record, student: students[0], section: section, recorded_by: teacher.user)
        end

        it "lets a student see only their own records" do
            create(:attendance_record, student: students[1], section: section,
                                       recorded_by: teacher.user, date: Date.new(2026, 9, 16))

            get "/api/v1/attendance_records", headers: authenticated_headers(students[0].user)

            expect(json_body["data"].pluck("student_id").uniq).to eq([students[0].id])
        end

        it "lets a parent see only their children's records" do
            parent = create(:parent, school: school)
            create(:parent_student, parent: parent, student: students[0])

            get "/api/v1/attendance_records", headers: authenticated_headers(parent.user)

            expect(json_body["data"].pluck("student_id").uniq).to eq([students[0].id])
        end

        it "does not leak records across schools" do
            foreign = create(:attendance_record)

            get "/api/v1/attendance_records", headers: authenticated_headers(admin)

            expect(json_body["data"].pluck("id")).not_to include(foreign.id)
        end
    end

    describe "PATCH /api/v1/attendance_records/:id" do
        it "allows the section teacher to correct a record" do
            record = create(:attendance_record, student: students[0], section: section,
                                                recorded_by: teacher.user)

            patch "/api/v1/attendance_records/#{record.id}",
                  params: { attendance_record: { status: "excused", note: "doctor visit" } }.to_json,
                  headers: authenticated_headers(teacher.user)

            expect(response).to have_http_status(:ok)
            expect(record.reload.status).to eq("excused")
        end

        it "forbids students from editing" do
            record = create(:attendance_record, student: students[0], section: section,
                                                recorded_by: teacher.user)

            patch "/api/v1/attendance_records/#{record.id}",
                  params: { attendance_record: { status: "present" } }.to_json,
                  headers: authenticated_headers(students[0].user)

            expect(response).to have_http_status(:forbidden)
        end
    end
end

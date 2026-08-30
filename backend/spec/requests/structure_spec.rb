# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Academic structure", type: :request do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:teacher) { create(:user, :teacher, school: school) }
    let(:year) { create(:academic_year, school: school) }

    describe "classes" do
        it "creates and lists classes (admin write, teacher read)" do
            post "/api/v1/classes",
                 params: { school_class: { name: "Grade 5", grade_level: 5, academic_year_id: year.id } }.to_json,
                 headers: authenticated_headers(admin)
            expect(response).to have_http_status(:created)

            get "/api/v1/classes", headers: authenticated_headers(teacher)
            expect(response).to have_http_status(:ok)
            expect(json_body["data"].length).to eq(1)

            post "/api/v1/classes",
                 params: { school_class: { name: "Grade 6", academic_year_id: year.id } }.to_json,
                 headers: authenticated_headers(teacher)
            expect(response).to have_http_status(:forbidden)
        end

        it "rejects duplicate class name within the same academic year" do
            create(:school_class, school: school, academic_year: year, name: "Grade 5")

            post "/api/v1/classes",
                 params: { school_class: { name: "Grade 5", academic_year_id: year.id } }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe "sections" do
        let(:klass) { create(:school_class, school: school, academic_year: year) }

        it "creates a section under a class and lists via nested route" do
            post "/api/v1/sections",
                 params: { section: { school_class_id: klass.id, name: "A", capacity: 25 } }.to_json,
                 headers: authenticated_headers(admin)
            expect(response).to have_http_status(:created)

            get "/api/v1/classes/#{klass.id}/sections", headers: authenticated_headers(teacher)
            expect(response).to have_http_status(:ok)
            expect(json_body["data"].first["name"]).to eq("A")
        end

        it "rejects duplicate section name within a class" do
            create(:section, school_class: klass, name: "A")

            post "/api/v1/sections",
                 params: { section: { school_class_id: klass.id, name: "A" } }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe "subjects" do
        it "enforces per-school unique code" do
            create(:subject, school: school, code: "MATH")

            post "/api/v1/subjects",
                 params: { subject: { name: "Mathematics", code: "MATH" } }.to_json,
                 headers: authenticated_headers(admin)

            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe "subject assignments" do
        it "creates an assignment and scopes teacher listing to own assignments" do
            teacher_profile = create(:teacher, school: school)
            other_teacher = create(:teacher, school: school)
            klass = create(:school_class, school: school, academic_year: year)
            section = create(:section, school_class: klass)
            subject_record = create(:subject, school: school)
            semester = create(:semester, academic_year: year)

            post "/api/v1/subject_assignments",
                 params: {
                     subject_assignment: {
                         teacher_id: teacher_profile.id,
                         subject_id: subject_record.id,
                         section_id: section.id,
                         semester_id: semester.id
                     }
                 }.to_json,
                 headers: authenticated_headers(admin)
            expect(response).to have_http_status(:created)

            create(:subject_assignment, school: school, teacher: other_teacher,
                                        subject: subject_record, section: section, semester: semester)

            get "/api/v1/subject_assignments", headers: authenticated_headers(teacher_profile.user)
            ids = json_body["data"].pluck("teacher_id").uniq
            expect(ids).to contain_exactly(teacher_profile.id)
        end
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/classes/#{create(:school_class).id}" }
        let(:requesting_user) { admin }
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/sections/#{create(:section).id}" }
        let(:requesting_user) { admin }
    end

    it_behaves_like "tenant isolated", :get do
        let(:other_record_path) { "/api/v1/subjects/#{create(:subject).id}" }
        let(:requesting_user) { admin }
    end
end

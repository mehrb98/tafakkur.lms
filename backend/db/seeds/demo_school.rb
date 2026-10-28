# frozen_string_literal: true

module Seeds
    # Production-shaped demo tenant: multi-department curriculum, grades 5–11 with
    # two sections each, subject teachers assigned to classes, families, attendance,
    # grades, announcements, and async report records.
    class DemoSchool
        DEMO_PASSWORD = "DemoPassword123!"
        GRADE_LEVELS = (5..11).freeze
        SECTION_NAMES = %w[A B].freeze
        STUDENTS_PER_SECTION = 18
        CORE_SUBJECT_CODES = %w[MAT ENG UZB HIS PHY BIO PE].freeze
        GRADE_TYPES = %w[quiz assignment exam].freeze

        DEPARTMENT_DEFS = [
            { key: :general, name: "General Studies", parent: nil,
              description: "Primary programs and homeroom coordination" },
            { key: :sciences, name: "Sciences", parent: :general, description: "STEM subjects" },
            { key: :languages, name: "Languages", parent: :general, description: "Modern languages" },
            { key: :humanities, name: "Humanities", parent: :general, description: "Social sciences" },
            { key: :arts, name: "Arts & Technology", parent: :general, description: "Creative and digital arts" },
            { key: :pe, name: "Physical Education", parent: :general, description: "Athletics and wellness" }
        ].freeze

        SUBJECT_DEFS = [
            { code: "MAT", name: "Mathematics", dept: :sciences },
            { code: "PHY", name: "Physics", dept: :sciences },
            { code: "BIO", name: "Biology", dept: :sciences },
            { code: "CHE", name: "Chemistry", dept: :sciences },
            { code: "ENG", name: "English", dept: :languages },
            { code: "UZB", name: "Uzbek Language", dept: :languages },
            { code: "RUS", name: "Russian Language", dept: :languages },
            { code: "HIS", name: "History", dept: :humanities },
            { code: "GEO", name: "Geography", dept: :humanities },
            { code: "CS", name: "Computer Science", dept: :arts },
            { code: "ART", name: "Visual Arts", dept: :arts },
            { code: "PE", name: "Physical Education", dept: :pe }
        ].freeze

        TEACHER_PROFILES = {
            "MAT" => %w[Dilshod Karimov],
            "PHY" => %w[Bekzod Tursunov],
            "BIO" => %w[Malika Yusupova],
            "CHE" => %w[Jasur Yusupov],
            "ENG" => %w[Nodira Saidova],
            "UZB" => %w[Gulnora Aliyeva],
            "RUS" => %w[Farhod Nazarov],
            "HIS" => %w[Azamat Rakhimov],
            "GEO" => %w[Shahlo Mirzayeva],
            "CS" => %w[Sardor Umarov],
            "ART" => %w[Nilufar Ergasheva],
            "PE" => %w[Rustam Jo'rayev]
        }.freeze

        def self.call
            new.call
        end

        def call
            Faker::Config.random = Random.new(42)

            @school = seed_school!
            Current.school = @school

            seed_subscription!
            @roles_by_system_role = seed_roles!
            @admin = seed_admin!
            Current.user = @admin

            @year = seed_academic_year!
            @semester = seed_semesters!
            @departments = seed_departments!
            @subjects = seed_subjects!
            @teachers_by_code = seed_subject_teachers!
            @homeroom_teachers = seed_homeroom_teachers!
            @sections = seed_classes_and_sections!
            seed_subject_assignments!
            @students = seed_students!
            seed_parents!
            seed_attendance!
            seed_grades!
            seed_announcements!
            seed_reports!
            seed_user_roles!
            seed_audit_and_sessions!
            seed_qr_login_samples!

            log_summary
        ensure
            Current.reset
        end

        private

        attr_reader :school, :admin, :year, :semester, :departments, :subjects,
                    :teachers_by_code, :homeroom_teachers, :sections, :students,
                    :roles_by_system_role

        def seed_school!
            School.find_or_create_by!(slug: "demo-school") do |record|
                record.name = "Tafakkur International School"
                record.timezone = "Asia/Tashkent"
                record.locale = "en"
                record.subscription_status = "active"
                record.settings = {
                    "address" => "45 Mustaqillik Avenue, Tashkent",
                    "phone" => "+998 71 123 4567",
                    "motto" => "Think deeply, act kindly"
                }
            end
        end

        def seed_subscription!
            Subscription.find_or_create_by!(school: school) do |sub|
                sub.plan = "pro"
                sub.status = "active"
                sub.current_period_start = Time.current.beginning_of_month
                sub.current_period_end = 1.year.from_now
                sub.metadata = { "seats" => 500, "billing_cycle" => "annual" }
            end
        end

        def seed_roles!
            User::ROLES.index_with do |system_role|
                Role.find_or_create_by!(school: school, system_role: system_role) do |role|
                    role.name = system_role.titleize
                    role.permissions = {}
                end
            end
        end

        def seed_admin!
            User.find_or_create_by!(school: school, email: "admin@demo.tafakkur.local") do |user|
                user.role = "admin"
                user.first_name = "Aziza"
                user.last_name = "Rahimova"
                user.password = DEMO_PASSWORD
                user.phone = "+998 90 100 0001"
                user.confirmed_at = Time.current
            end
        end

        def seed_academic_year!
            AcademicYear.find_or_create_by!(school: school, name: "2026-2027") do |record|
                record.start_date = Date.new(2026, 9, 1)
                record.end_date = Date.new(2027, 6, 30)
                record.is_current = true
            end
        end

        def seed_semesters!
            first = Semester.find_or_create_by!(school: school, academic_year: year, name: "Semester 1") do |record|
                record.start_date = year.start_date
                record.end_date = Date.new(2026, 12, 31)
            end
            
            Semester.find_or_create_by!(school: school, academic_year: year, name: "Semester 2") do |record|
                record.start_date = Date.new(2027, 1, 15)
                record.end_date = year.end_date
            end
            first
        end

        def seed_departments!
            created = {}
            DEPARTMENT_DEFS.each do |definition|
                created[definition[:key]] = Department.find_or_create_by!(school: school, name: definition[:name]) do |dept|
                    dept.description = definition[:description]
                    dept.parent = created[definition[:parent]] if definition[:parent]
                end
            end
            created
        end

        def seed_subjects!
            SUBJECT_DEFS.to_h do |definition|
                subject = Subject.find_or_create_by!(school: school, code: definition[:code]) do |record|
                    record.name = definition[:name]
                    record.department = departments[definition[:dept]]
                end
                [definition[:code], subject]
            end
        end

        def seed_subject_teachers!
            SUBJECT_DEFS.to_h do |definition|
                code = definition[:code]
                first_name, last_name = TEACHER_PROFILES.fetch(code, ["Teacher", code])
                email = "teacher.#{code.downcase}@demo.tafakkur.local"
                user = User.find_or_create_by!(school: school, email: email) do |record|
                    record.role = "teacher"
                    record.first_name = first_name
                    record.last_name = last_name
                    record.password = DEMO_PASSWORD
                    record.confirmed_at = Time.current
                end
                teacher = Teacher.find_or_create_by!(school: school, user: user) do |record|
                    record.employee_code = "TCH-#{code}"
                    record.specialization = definition[:name]
                    record.department = departments[definition[:dept]]
                    record.hire_date = Date.new(2023, 9, 1)
                end
                [code, teacher]
            end
        end

        def seed_homeroom_teachers!
            %w[homeroom.north homeroom.south].map.with_index(1) do |slug, index|
                email = "teacher.#{slug}@demo.tafakkur.local"
                user = User.find_or_create_by!(school: school, email: email) do |record|
                    record.role = "teacher"
                    record.first_name = "Homeroom"
                    record.last_name = index == 1 ? "North" : "South"
                    record.password = DEMO_PASSWORD
                    record.confirmed_at = Time.current
                end
                Teacher.find_or_create_by!(school: school, user: user) do |record|
                    record.employee_code = "HR-#{index}"
                    record.specialization = "Homeroom"
                    record.department = departments[:general]
                    record.hire_date = Date.new(2022, 9, 1)
                end
            end
        end

        def seed_classes_and_sections!
            homeroom_pool = teachers_by_code.values + homeroom_teachers
            sections = []
            homeroom_index = 0

            GRADE_LEVELS.each do |grade_level|
                school_class = SchoolClass.find_or_create_by!(
                    school: school, academic_year: year, name: "Grade #{grade_level}"
                ) do |record|
                    record.grade_level = grade_level
                    record.department = departments[:general]
                end

                SECTION_NAMES.each do |section_name|
                    homeroom = homeroom_pool[homeroom_index % homeroom_pool.size]
                    homeroom_index += 1

                    section = Section.find_or_create_by!(
                        school: school, school_class: school_class, name: section_name
                    ) do |record|
                        record.capacity = 30
                        record.homeroom_teacher = homeroom
                    end
                    sections << section
                end
            end
            sections
        end

        def seed_subject_assignments!
            sections.each do |section|
                CORE_SUBJECT_CODES.each do |code|
                    SubjectAssignment.find_or_create_by!(
                        school: school,
                        teacher: teachers_by_code.fetch(code),
                        subject: subjects.fetch(code),
                        section: section,
                        semester: semester
                    )
                end
            end
        end

        def seed_students!
            students = []
            GRADE_LEVELS.each do |grade_level|
                SECTION_NAMES.each do |section_name|
                    STUDENTS_PER_SECTION.times do |index|
                        number = index + 1
                        email = student_email(grade_level, section_name, number)
                        first_name = Faker::Name.first_name
                        last_name = Faker::Name.last_name
                        user = User.find_or_create_by!(school: school, email: email) do |record|
                            record.role = "student"
                            record.first_name = first_name
                            record.last_name = last_name
                            record.password = DEMO_PASSWORD
                            record.confirmed_at = Time.current
                        end
                        student = Student.find_or_create_by!(school: school, user: user) do |record|
                            record.student_code = student_code(grade_level, section_name, number)
                            record.date_of_birth = Date.new(2026 - grade_level - 5, 3, 15)
                            record.gender = number.even? ? "female" : "male"
                            record.admission_date = Date.new(2024, 9, 1)
                            record.address = Faker::Address.full_address
                        end
                        section = sections.find do |candidate|
                            candidate.school_class.grade_level == grade_level && candidate.name == section_name
                        end
                        Enrollment.find_or_create_by!(school: school, student: student, academic_year: year) do |record|
                            record.section = section
                            record.status = "active"
                            record.enrolled_on = year.start_date
                        end
                        students << student
                    end
                end
            end
            link_sibling_family!(students)
            students
        end

        def link_sibling_family!(students)
            malika = students.find { |s| s.user.email == student_email(5, "A", 18) }
            jasur = students.find { |s| s.user.email == student_email(6, "B", 1) }
            return unless malika && jasur

            malika.user.update!(last_name: "Yusupova")
            jasur.user.update!(last_name: "Yusupov")

            parent_user = User.find_or_create_by!(school: school, email: "parent.yusupov@demo.tafakkur.local") do |record|
                record.role = "parent"
                record.first_name = "Olim"
                record.last_name = "Yusupov"
                record.password = DEMO_PASSWORD
                record.phone = "+998 90 200 0018"
                record.confirmed_at = Time.current
            end
            parent = Parent.find_or_create_by!(school: school, user: parent_user) do |record|
                record.occupation = "Software engineer"
            end
            [malika, jasur].each do |child|
                ParentStudent.find_or_create_by!(school: school, parent: parent, student: child) do |link|
                    link.relationship = "father"
                end
            end
        end

        def seed_parents!
            students.each do |student|
                next if ParentStudent.exists?(student: student)

                user = student.user
                email = "parent.#{user.email.sub('@demo.tafakkur.local', '')}@demo.tafakkur.local"
                parent_user = User.find_or_create_by!(school: school, email: email) do |record|
                    record.role = "parent"
                    record.first_name = Faker::Name.first_name
                    record.last_name = user.last_name
                    record.password = DEMO_PASSWORD
                    record.confirmed_at = Time.current
                end
                parent = Parent.find_or_create_by!(school: school, user: parent_user) do |record|
                    record.occupation = Faker::Job.title
                end
                ParentStudent.find_or_create_by!(school: school, parent: parent, student: student) do |link|
                    link.relationship = %w[father mother guardian].sample
                end
            end
        end

        def seed_attendance!
            attendance_window = (Date.new(2026, 9, 1)..Date.new(2026, 10, 15)).reject(&:on_weekend?)
            students.each do |student|
                enrollment = student.enrollments.active.find_by!(academic_year: year)
                section = enrollment.section
                recorder = section.homeroom_teacher&.user || admin
                attendance_window.each do |date|
                    AttendanceRecord.find_or_create_by!(student: student, section: section, date: date) do |record|
                        record.school = school
                        record.status = weighted_attendance_status
                        record.recorded_by = recorder
                    end
                end
            end
        end

        def seed_grades!
            students.each do |student|
                CORE_SUBJECT_CODES.each do |code|
                    teacher = teachers_by_code.fetch(code)
                    subject = subjects.fetch(code)
                    GRADE_TYPES.each do |grade_type|
                        next if Grade.exists?(
                            student: student, subject: subject, semester: semester, grade_type: grade_type
                        )

                        Grade.create!(
                            school: school,
                            student: student,
                            subject: subject,
                            semester: semester,
                            teacher: teacher,
                            grade_type: grade_type,
                            value: grade_value_for(student, code, grade_type),
                            max_value: 100,
                            graded_on: Date.new(2026, 10, 1),
                            comment: grade_type == "exam" ? "Mid-term assessment" : nil
                        )
                    end
                end
            end
        end

        def seed_announcements!
            sample_section = sections.first
            announcements = [
                {
                    title: "Mid-term exam timetable published",
                    body: "<p>Examinations for Semester 1 run from 4–15 November. Room lists are on the portal.</p>",
                    target_type: "all",
                    target_ids: [],
                    published_at: 2.days.ago,
                    author: admin
                },
                {
                    title: "Parent–teacher conferences (Grades 5–7)",
                    body: "<p>Sign up for a 15-minute slot between 08:00 and 16:00 next Monday.</p>",
                    target_type: "role",
                    target_ids: ["parent"],
                    published_at: 1.day.ago,
                    author: admin
                },
                {
                    title: "Grade 5-A museum visit permission",
                    body: "<p>Please confirm attendance for the history museum trip on 22 October.</p>",
                    target_type: "section",
                    target_ids: [sample_section.id],
                    published_at: 3.days.ago,
                    author: teachers_by_code.fetch("HIS").user
                },
                {
                    title: "Staff planning day (draft)",
                    body: "<p>Internal draft — not yet published to parents.</p>",
                    target_type: "role",
                    target_ids: ["teacher"],
                    published_at: nil,
                    author: admin
                }
            ]

            announcements.each do |definition|
                Announcement.find_or_create_by!(school: school, title: definition[:title]) do |record|
                    record.author = definition[:author]
                    record.body = definition[:body]
                    record.target_type = definition[:target_type]
                    record.target_ids = definition[:target_ids]
                    record.published_at = definition[:published_at]
                end
            end
        end

        def seed_reports!
            sample_section = sections.find { |s| s.school_class.grade_level == 9 && s.name == "A" }
            math_teacher = teachers_by_code.fetch("MAT")

            Report.find_or_create_by!(
                school: school,
                requested_by: admin,
                report_type: "attendance",
                status: "completed"
            ) do |record|
                record.parameters = {
                    section_id: sample_section.id,
                    date_from: "2026-09-01",
                    date_to: "2026-10-15",
                    format: "pdf"
                }
                record.file_url = "https://demo.tafakkur.local/reports/attendance-grade9a.pdf"
                record.completed_at = 2.hours.ago
                record.expires_at = 22.hours.from_now
            end

            Report.find_or_create_by!(
                school: school,
                requested_by: math_teacher.user,
                report_type: "grades",
                status: "processing"
            ) do |record|
                record.parameters = {
                    section_id: sample_section.id,
                    semester_id: semester.id,
                    format: "csv"
                }
            end

            Report.find_or_create_by!(
                school: school,
                requested_by: admin,
                report_type: "enrollment",
                status: "pending"
            ) do |record|
                record.parameters = {
                    academic_year_id: year.id,
                    format: "pdf"
                }
            end
        end

        def seed_user_roles!
            User.where(school: school).find_each do |user|
                role = roles_by_system_role[user.role]
                next unless role

                UserRole.find_or_create_by!(user: user, role: role) do |user_role|
                    user_role.school = school
                end
            end
        end

        def seed_audit_and_sessions!
            unless AuditLog.exists?(school: school, user: admin, action: "seed.completed")
                AuditLog.record!(
                    user: admin,
                    action: "seed.completed",
                    metadata: {
                        source: "db:seed",
                        school_slug: school.slug,
                        students: students.size,
                        sections: sections.size
                    }
                )
            end

            seed_ip = IPAddr.new("127.0.0.1")
            seed_user_agent = "TafakkurSeed/1.0 (db:seed)"

            unless DeviceSession.exists?(user: admin, device_name: "Demo MacBook (seed)")
                _raw_refresh, refresh_record = RefreshToken.issue!(
                    user: admin,
                    remember_me: true,
                    device_name: "Demo MacBook (seed)",
                    ip_address: seed_ip,
                    user_agent: seed_user_agent
                )
                DeviceSession.find_or_create_by!(refresh_token: refresh_record) do |session|
                    session.user = admin
                    session.school = school
                    session.device_name = "Demo MacBook (seed)"
                    session.ip_address = seed_ip
                    session.last_active_at = Time.current
                end
            end

            return if RefreshToken.exists?(user: admin, device_name: "Revoked demo session")

            _revoked_raw, revoked_record = RefreshToken.issue!(
                user: admin,
                device_name: "Revoked demo session",
                ip_address: seed_ip,
                user_agent: seed_user_agent
            )
            revoked_record.revoke!
        end

        def seed_qr_login_samples!
            seed_ip = IPAddr.new("127.0.0.1")
            seed_user_agent = "TafakkurSeed/1.0 (db:seed)"

            QrLoginRequest.find_or_create_by!(token_digest: QrLoginRequest.digest("seed-demo-qr-pending")) do |request|
                request.poll_secret_digest = QrLoginRequest.digest("seed-demo-poll-pending")
                request.status = "pending"
                request.expires_at = 1.hour.from_now
                request.device_name = "Demo Browser"
                request.ip_address = seed_ip
                request.user_agent = seed_user_agent
            end

            QrLoginRequest.find_or_create_by!(token_digest: QrLoginRequest.digest("seed-demo-qr-consumed")) do |request|
                request.poll_secret_digest = QrLoginRequest.digest("seed-demo-poll-consumed")
                request.status = "consumed"
                request.user = admin
                request.school = school
                request.expires_at = 1.hour.from_now
                request.approved_at = 10.minutes.ago
                request.consumed_at = 5.minutes.ago
                request.approved_ip_address = seed_ip
                request.device_name = "Demo Phone"
                request.ip_address = seed_ip
                request.user_agent = seed_user_agent
            end
        end

        def student_email(grade_level, section_name, number)
            "student.g#{grade_level}#{section_name.downcase}.#{format('%02d', number)}@demo.tafakkur.local"
        end

        def student_code(grade_level, section_name, number)
            "G#{grade_level}#{section_name}-#{format('%03d', number)}"
        end

        def weighted_attendance_status
            %w[present present present present late absent excused].sample
        end

        def grade_value_for(student, code, grade_type)
            base = 60 + (student.student_code.sum % 25)
            offset = { "MAT" => 8, "ENG" => 5, "UZB" => 10, "HIS" => 3, "PHY" => 0, "BIO" => 4, "PE" => 12 }.fetch(code, 0)
            adjustment = { "quiz" => -3, "assignment" => 0, "exam" => 5 }.fetch(grade_type, 0)
            [base + offset + adjustment, 100].min
        end

        def log_summary
            Rails.logger.debug do
                <<~MSG.strip
                    Demo school seeded: #{sections.size} sections, #{students.size} students,
                    #{subjects.size} subjects, #{departments.size} departments.
                    Login: admin@demo.tafakkur.local / #{DEMO_PASSWORD}
                    Sample teacher: teacher.mat@demo.tafakkur.local / #{DEMO_PASSWORD}
                    Sample student: #{student_email(5, 'A', 1)} / #{DEMO_PASSWORD}
                MSG
            end
        end
    end
end

# frozen_string_literal: true

require "faker"

abort "Refusing to seed a production database." if Rails.env.production?

Rails.logger.debug "Seeding Tafakkur LMS demo data..."

ActiveRecord::Base.transaction do
    school = School.find_or_create_by!(slug: "demo-school") do |s|
        s.name = "Tafakkur Demo School"
        s.timezone = "Asia/Tashkent"
        s.locale = "en"
        s.subscription_status = "active"
    end

    Current.school = school

    Subscription.find_or_create_by!(school: school) do |sub|
        sub.plan = "pro"
        sub.status = "active"
        sub.current_period_start = Time.current.beginning_of_month
        sub.current_period_end = 1.year.from_now
    end

    password = "DemoPassword123!"

    admin = User.find_or_create_by!(school: school, email: "admin@demo.tafakkur.local") do |u|
        u.role = "admin"
        u.first_name = "Aziza"
        u.last_name = "Rahimova"
        u.password = password
        u.confirmed_at = Time.current
    end
    Current.user = admin

    year = AcademicYear.find_or_create_by!(school: school, name: "2026-2027") do |y|
        y.start_date = Date.new(2026, 9, 1)
        y.end_date = Date.new(2027, 6, 30)
        y.is_current = true
    end

    semester = Semester.find_or_create_by!(school: school, academic_year: year, name: "Semester 1") do |s|
        s.start_date = year.start_date
        s.end_date = Date.new(2026, 12, 31)
    end

    department = Department.find_or_create_by!(school: school, name: "General Studies")

    subjects = %w[Mathematics English Science History].map do |name|
        Subject.find_or_create_by!(school: school, code: name[0..2].upcase) do |subj|
            subj.name = name
            subj.department = department
        end
    end

    teachers = Array.new(4) do |i|
        email = "teacher#{i + 1}@demo.tafakkur.local"
        user = User.find_or_create_by!(school: school, email: email) do |u|
            u.role = "teacher"
            u.first_name = Faker::Name.first_name
            u.last_name = Faker::Name.last_name
            u.password = password
            u.confirmed_at = Time.current
        end
        Teacher.find_or_create_by!(school: school, user: user) do |t|
            t.employee_code = "EMP#{(i + 1).to_s.rjust(4, '0')}"
            t.specialization = subjects[i].name
            t.department = department
            t.hire_date = Date.new(2024, 9, 1)
        end
    end

    klass = SchoolClass.find_or_create_by!(school: school, academic_year: year, name: "Grade 5") do |c|
        c.grade_level = 5
        c.department = department
    end

    section = Section.find_or_create_by!(school: school, school_class: klass, name: "A") do |s|
        s.capacity = 30
        s.homeroom_teacher = teachers.first
    end

    teachers.each_with_index do |teacher, i|
        SubjectAssignment.find_or_create_by!(
            school: school, teacher: teacher, subject: subjects[i],
            section: section, semester: semester
        )
    end

    students = Array.new(15) do |i|
        email = "student#{i + 1}@demo.tafakkur.local"
        user = User.find_or_create_by!(school: school, email: email) do |u|
            u.role = "student"
            u.first_name = Faker::Name.first_name
            u.last_name = Faker::Name.last_name
            u.password = password
            u.confirmed_at = Time.current
        end
        student = Student.find_or_create_by!(school: school, user: user) do |s|
            s.student_code = "STU#{(i + 1).to_s.rjust(4, '0')}"
            s.date_of_birth = Faker::Date.between(from: "2011-01-01", to: "2013-12-31")
            s.gender = %w[male female].sample
            s.admission_date = Date.new(2024, 9, 1)
        end
        Enrollment.find_or_create_by!(school: school, student: student, academic_year: year) do |e|
            e.section = section
            e.status = "active"
            e.enrolled_on = year.start_date
        end
        student
    end

    students.first(10).each_with_index do |student, i|
        email = "parent#{i + 1}@demo.tafakkur.local"
        user = User.find_or_create_by!(school: school, email: email) do |u|
            u.role = "parent"
            u.first_name = Faker::Name.first_name
            u.last_name = Faker::Name.last_name
            u.password = password
            u.confirmed_at = Time.current
        end
        parent = Parent.find_or_create_by!(school: school, user: user) do |p|
            p.occupation = Faker::Job.title
        end
        ParentStudent.find_or_create_by!(school: school, parent: parent, student: student) do |link|
            link.relationship = %w[father mother].sample
        end
    end

    # Two weeks of attendance
    (Date.new(2026, 9, 14)..Date.new(2026, 9, 25)).reject(&:on_weekend?).each do |date|
        students.each do |student|
            AttendanceRecord.find_or_create_by!(student: student, section: section, date: date) do |r|
                r.school = school
                r.status = %w[present present present present late absent].sample
                r.recorded_by = teachers.first.user
            end
        end
    end

    # Grades per subject
    students.each do |student|
        subjects.each_with_index do |subj, i|
            next if Grade.exists?(student: student, subject: subj, semester: semester, grade_type: "quiz")

            Grade.create!(
                school: school,
                student: student,
                subject: subj,
                semester: semester,
                teacher: teachers[i],
                grade_type: "quiz",
                value: rand(55..100),
                max_value: 100,
                graded_on: Date.new(2026, 10, 1)
            )
        end
    end
ensure
    Current.reset
end

Rails.logger.debug "Done. Login: admin@demo.tafakkur.local / DemoPassword123!"

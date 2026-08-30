# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_09_000022) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"

  create_table "academic_years", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.date "end_date", null: false
    t.boolean "is_current", default: false, null: false
    t.string "name", limit: 100, null: false
    t.uuid "school_id", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "name"], name: "index_academic_years_on_school_id_and_name", unique: true
    t.index ["school_id"], name: "index_academic_years_one_current_per_school", unique: true, where: "(is_current = true)"
  end

  create_table "attendance_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "note"
    t.uuid "recorded_by_id", null: false
    t.uuid "school_id", null: false
    t.uuid "section_id", null: false
    t.string "status", limit: 16, null: false
    t.uuid "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recorded_by_id"], name: "index_attendance_records_on_recorded_by_id"
    t.index ["school_id", "section_id", "date"], name: "index_attendance_records_on_school_id_and_section_id_and_date"
    t.index ["school_id", "student_id", "date"], name: "index_attendance_records_on_school_id_and_student_id_and_date"
    t.index ["student_id", "section_id", "date"], name: "index_attendance_uniqueness", unique: true
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", limit: 64, null: false
    t.uuid "auditable_id"
    t.string "auditable_type", limit: 64
    t.datetime "created_at", null: false
    t.inet "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "school_id", null: false
    t.uuid "user_id"
    t.index ["school_id", "auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["school_id", "created_at"], name: "index_audit_logs_on_school_id_and_created_at", order: { created_at: :desc }
    t.index ["school_id", "user_id", "created_at"], name: "index_audit_logs_on_school_user_activity", order: { created_at: :desc }
  end

  create_table "departments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "name", limit: 150, null: false
    t.uuid "parent_id"
    t.uuid "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_departments_on_parent_id"
    t.index ["school_id", "name"], name: "index_departments_on_school_id_and_name", unique: true
  end

  create_table "device_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_name", limit: 255, null: false
    t.inet "ip_address"
    t.datetime "last_active_at", null: false
    t.uuid "refresh_token_id", null: false
    t.uuid "school_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["refresh_token_id"], name: "index_device_sessions_on_refresh_token_id", unique: true
    t.index ["school_id"], name: "index_device_sessions_on_school_id"
    t.index ["user_id", "last_active_at"], name: "index_device_sessions_on_user_activity", order: { last_active_at: :desc }
  end

  create_table "enrollments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academic_year_id", null: false
    t.datetime "created_at", null: false
    t.date "enrolled_on", null: false
    t.uuid "school_id", null: false
    t.uuid "section_id", null: false
    t.string "status", limit: 32, default: "active", null: false
    t.uuid "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_enrollments_on_academic_year_id"
    t.index ["school_id", "section_id", "status"], name: "index_enrollments_on_school_id_and_section_id_and_status"
    t.index ["section_id"], name: "index_enrollments_on_section_id"
    t.index ["student_id", "academic_year_id"], name: "index_enrollments_one_active_per_year", unique: true, where: "((status)::text = 'active'::text)"
    t.index ["student_id", "status"], name: "index_enrollments_on_student_id_and_status"
  end

  create_table "grades", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.string "grade_type", limit: 32, null: false
    t.date "graded_on", null: false
    t.decimal "max_value", precision: 6, scale: 2, default: "100.0", null: false
    t.uuid "school_id", null: false
    t.uuid "semester_id", null: false
    t.uuid "student_id", null: false
    t.uuid "subject_id", null: false
    t.uuid "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 6, scale: 2, null: false
    t.index ["school_id", "student_id", "semester_id"], name: "index_grades_on_school_id_and_student_id_and_semester_id"
    t.index ["school_id", "teacher_id", "graded_on"], name: "index_grades_on_school_id_and_teacher_id_and_graded_on"
    t.index ["semester_id"], name: "index_grades_on_semester_id"
    t.index ["student_id", "subject_id", "semester_id"], name: "index_grades_on_student_id_and_subject_id_and_semester_id"
    t.index ["subject_id"], name: "index_grades_on_subject_id"
    t.index ["teacher_id"], name: "index_grades_on_teacher_id"
    t.check_constraint "value >= 0::numeric AND value <= max_value", name: "grades_value_within_bounds"
  end

  create_table "parent_students", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "parent_id", null: false
    t.string "relationship", limit: 32, null: false
    t.uuid "school_id", null: false
    t.uuid "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "student_id"], name: "index_parent_students_on_parent_id_and_student_id", unique: true
    t.index ["school_id"], name: "index_parent_students_on_school_id"
    t.index ["student_id"], name: "index_parent_students_on_student_id"
  end

  create_table "parents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "occupation", limit: 150
    t.uuid "school_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["school_id"], name: "index_parents_on_school_id_kept", where: "(discarded_at IS NULL)"
    t.index ["user_id"], name: "index_parents_on_user_id", unique: true
  end

  create_table "refresh_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_name", limit: 255
    t.datetime "expires_at", null: false
    t.inet "ip_address"
    t.uuid "replaced_by_id"
    t.datetime "revoked_at"
    t.uuid "school_id", null: false
    t.string "token_digest", limit: 255, null: false
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.uuid "user_id", null: false
    t.index ["expires_at"], name: "index_refresh_tokens_expiring", where: "(revoked_at IS NULL)"
    t.index ["replaced_by_id"], name: "index_refresh_tokens_on_replaced_by_id"
    t.index ["school_id"], name: "index_refresh_tokens_on_school_id"
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id", "revoked_at"], name: "index_refresh_tokens_active", where: "(revoked_at IS NULL)"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", limit: 64, null: false
    t.jsonb "permissions", default: {}, null: false
    t.uuid "school_id", null: false
    t.string "system_role", limit: 32
    t.datetime "updated_at", null: false
    t.index ["school_id", "name"], name: "index_roles_on_school_id_and_name", unique: true
  end

  create_table "school_classes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academic_year_id", null: false
    t.datetime "created_at", null: false
    t.uuid "department_id"
    t.datetime "discarded_at"
    t.integer "grade_level"
    t.string "name", limit: 100, null: false
    t.uuid "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_school_classes_on_academic_year_id"
    t.index ["department_id"], name: "index_school_classes_on_department_id"
    t.index ["school_id", "academic_year_id", "name"], name: "idx_on_school_id_academic_year_id_name_6c757db4cf", unique: true
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "domain", limit: 255
    t.string "locale", limit: 10, default: "en", null: false
    t.string "name", limit: 255, null: false
    t.jsonb "settings", default: {}, null: false
    t.string "slug", limit: 100, null: false
    t.string "subscription_status", limit: 32, default: "trial", null: false
    t.string "timezone", limit: 64, default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_schools_on_discarded_at", where: "(discarded_at IS NULL)"
    t.index ["domain"], name: "index_schools_on_domain", unique: true, where: "(domain IS NOT NULL)"
    t.index ["slug"], name: "index_schools_on_slug", unique: true
  end

  create_table "sections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "capacity", default: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.uuid "homeroom_teacher_id"
    t.string "name", limit: 50, null: false
    t.uuid "school_class_id", null: false
    t.uuid "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["homeroom_teacher_id"], name: "index_sections_on_homeroom_teacher_id"
    t.index ["school_class_id", "name"], name: "index_sections_on_school_class_id_and_name", unique: true
    t.index ["school_class_id"], name: "index_sections_on_school_class_id"
    t.index ["school_id", "school_class_id"], name: "index_sections_on_school_id_and_school_class_id"
  end

  create_table "semesters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academic_year_id", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.date "end_date", null: false
    t.string "name", limit: 100, null: false
    t.uuid "school_id", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id", "name"], name: "index_semesters_on_academic_year_id_and_name", unique: true
    t.index ["academic_year_id"], name: "index_semesters_on_academic_year_id"
    t.index ["school_id", "academic_year_id"], name: "index_semesters_on_school_id_and_academic_year_id"
  end

  create_table "students", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.date "admission_date"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.datetime "discarded_at"
    t.string "gender", limit: 16
    t.uuid "school_id", null: false
    t.string "student_code", limit: 32, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["school_id", "student_code"], name: "index_students_on_school_id_and_student_code", unique: true
    t.index ["school_id"], name: "index_students_on_school_id_kept", where: "(discarded_at IS NULL)"
    t.index ["student_code"], name: "index_students_on_student_code_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["user_id"], name: "index_students_on_user_id", unique: true
  end

  create_table "subject_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "school_id", null: false
    t.uuid "section_id", null: false
    t.uuid "semester_id", null: false
    t.uuid "subject_id", null: false
    t.uuid "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "teacher_id"], name: "index_subject_assignments_on_school_id_and_teacher_id"
    t.index ["section_id"], name: "index_subject_assignments_on_section_id"
    t.index ["semester_id"], name: "index_subject_assignments_on_semester_id"
    t.index ["subject_id"], name: "index_subject_assignments_on_subject_id"
    t.index ["teacher_id", "subject_id", "section_id", "semester_id"], name: "index_subject_assignments_uniqueness", unique: true
    t.index ["teacher_id"], name: "index_subject_assignments_on_teacher_id"
  end

  create_table "subjects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", limit: 32, null: false
    t.datetime "created_at", null: false
    t.uuid "department_id"
    t.datetime "discarded_at"
    t.string "name", limit: 150, null: false
    t.uuid "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_subjects_on_department_id"
    t.index ["school_id", "code"], name: "index_subjects_on_school_id_and_code", unique: true
    t.index ["school_id", "name"], name: "index_subjects_on_school_id_and_name"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_period_end", null: false
    t.datetime "current_period_start", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "plan", limit: 64, default: "starter", null: false
    t.uuid "school_id", null: false
    t.string "status", limit: 32, default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_subscriptions_on_school_id", unique: true
    t.index ["status", "current_period_end"], name: "index_subscriptions_on_status_and_current_period_end"
  end

  create_table "teachers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "department_id"
    t.datetime "discarded_at"
    t.string "employee_code", limit: 32, null: false
    t.date "hire_date"
    t.uuid "school_id", null: false
    t.string "specialization", limit: 150
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["department_id"], name: "index_teachers_on_department_id"
    t.index ["school_id", "employee_code"], name: "index_teachers_on_school_id_and_employee_code", unique: true
    t.index ["school_id"], name: "index_teachers_on_school_id_kept", where: "(discarded_at IS NULL)"
    t.index ["user_id"], name: "index_teachers_on_user_id", unique: true
  end

  create_table "user_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "role_id", null: false
    t.uuid "school_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["school_id"], name: "index_user_roles_on_school_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "avatar_url", limit: 512
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.datetime "discarded_at"
    t.string "email", limit: 255, null: false
    t.boolean "email_deliverable", default: true, null: false
    t.string "encrypted_password", limit: 255, null: false
    t.string "first_name", limit: 100, null: false
    t.string "last_name", limit: 100, null: false
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.string "phone", limit: 32
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", limit: 32, null: false
    t.uuid "school_id", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index "((((first_name)::text || ' '::text) || (last_name)::text)) gin_trgm_ops", name: "index_users_on_full_name_trgm", using: :gin
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id", "email"], name: "index_users_on_school_id_and_email", unique: true
    t.index ["school_id", "role"], name: "index_users_on_school_id_and_role"
    t.index ["school_id"], name: "index_users_on_school_id_kept", where: "(discarded_at IS NULL)"
  end

  add_foreign_key "academic_years", "schools"
  add_foreign_key "attendance_records", "schools"
  add_foreign_key "attendance_records", "sections"
  add_foreign_key "attendance_records", "students"
  add_foreign_key "attendance_records", "users", column: "recorded_by_id"
  add_foreign_key "audit_logs", "schools"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "departments", "departments", column: "parent_id"
  add_foreign_key "departments", "schools"
  add_foreign_key "device_sessions", "refresh_tokens"
  add_foreign_key "device_sessions", "schools"
  add_foreign_key "device_sessions", "users"
  add_foreign_key "enrollments", "academic_years"
  add_foreign_key "enrollments", "schools"
  add_foreign_key "enrollments", "sections"
  add_foreign_key "enrollments", "students"
  add_foreign_key "grades", "schools"
  add_foreign_key "grades", "semesters"
  add_foreign_key "grades", "students"
  add_foreign_key "grades", "subjects"
  add_foreign_key "grades", "teachers"
  add_foreign_key "parent_students", "parents"
  add_foreign_key "parent_students", "schools"
  add_foreign_key "parent_students", "students"
  add_foreign_key "parents", "schools"
  add_foreign_key "parents", "users"
  add_foreign_key "refresh_tokens", "refresh_tokens", column: "replaced_by_id"
  add_foreign_key "refresh_tokens", "schools"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "roles", "schools"
  add_foreign_key "school_classes", "academic_years"
  add_foreign_key "school_classes", "departments"
  add_foreign_key "school_classes", "schools"
  add_foreign_key "sections", "school_classes"
  add_foreign_key "sections", "schools"
  add_foreign_key "sections", "teachers", column: "homeroom_teacher_id"
  add_foreign_key "semesters", "academic_years"
  add_foreign_key "semesters", "schools"
  add_foreign_key "students", "schools"
  add_foreign_key "students", "users"
  add_foreign_key "subject_assignments", "schools"
  add_foreign_key "subject_assignments", "sections"
  add_foreign_key "subject_assignments", "semesters"
  add_foreign_key "subject_assignments", "subjects"
  add_foreign_key "subject_assignments", "teachers"
  add_foreign_key "subjects", "departments"
  add_foreign_key "subjects", "schools"
  add_foreign_key "subscriptions", "schools"
  add_foreign_key "teachers", "departments"
  add_foreign_key "teachers", "schools"
  add_foreign_key "teachers", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "schools"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "schools"
end

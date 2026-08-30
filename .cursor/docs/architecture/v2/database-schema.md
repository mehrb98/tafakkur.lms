# Database Schema — Tafakkur LMS v2.0

> **Master document:** [SAD.md §5](./SAD.md#5-database-design)

**Database:** PostgreSQL 16  
**Conventions:** UUID v7 primary keys, `school_id` tenant isolation, soft delete via `discarded_at`

---

## Table of Contents

1. [Conventions](#1-conventions)
2. [Tenant & Billing](#2-tenant--billing)
3. [Authentication & Sessions](#3-authentication--sessions)
4. [Users & Profiles](#4-users--profiles)
5. [Academic Structure](#5-academic-structure)
6. [Scheduling & Lessons](#6-scheduling--lessons)
7. [Academic Operations](#7-academic-operations)
8. [Communication](#8-communication)
9. [Files & Audit](#9-files--audit)
10. [Active Storage](#10-active-storage)
11. [Index Summary](#11-index-summary)

---

## 1. Conventions

| Rule | Standard |
|------|----------|
| Primary key | `id UUID PRIMARY KEY DEFAULT gen_random_uuid()` |
| Timestamps | `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`, `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` |
| Soft delete | `discarded_at TIMESTAMPTZ NULL` — partial indexes use `WHERE discarded_at IS NULL` |
| Tenant FK | `school_id UUID NOT NULL REFERENCES schools(id)` on all tenant-owned tables |
| Audit | `created_by_id UUID REFERENCES users(id)`, `updated_by_id UUID REFERENCES users(id)` on mutable entities |

---

## 2. Tenant & Billing

### 2.1 schools

**Purpose:** Root tenant entity. Every school is an independent organization.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| name | VARCHAR(255) | NOT NULL | Display name |
| slug | VARCHAR(100) | NOT NULL, UNIQUE | URL-safe identifier for routing |
| domain | VARCHAR(255) | UNIQUE, NULL | Custom domain (optional) |
| timezone | VARCHAR(64) | NOT NULL, DEFAULT 'UTC' | IANA timezone |
| locale | VARCHAR(10) | NOT NULL, DEFAULT 'en' | Default language |
| settings | JSONB | NOT NULL, DEFAULT '{}' | Branding, feature flags, file limits |
| subscription_status | VARCHAR(32) | NOT NULL, DEFAULT 'trial' | active, trial, suspended, cancelled |
| discarded_at | TIMESTAMPTZ | NULL | Soft delete |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(slug)` | slug | Fast tenant lookup by slug; routing |
| `UNIQUE(domain) WHERE domain IS NOT NULL` | domain | Custom domain resolution; partial because most schools have no custom domain |
| `INDEX(discarded_at) WHERE discarded_at IS NULL` | discarded_at | Exclude soft-deleted schools from active queries |

**Relationships:** Has many of all tenant-owned entities.

---

### 2.2 subscriptions

**Purpose:** Billing plan and status per school.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id), UNIQUE | One subscription per school |
| plan | VARCHAR(64) | NOT NULL, DEFAULT 'starter' | starter, pro, enterprise |
| status | VARCHAR(32) | NOT NULL, DEFAULT 'active' | active, past_due, cancelled |
| current_period_start | TIMESTAMPTZ | NOT NULL | Billing period start |
| current_period_end | TIMESTAMPTZ | NOT NULL | Billing period end |
| metadata | JSONB | NOT NULL, DEFAULT '{}' | Stripe/payment provider data |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id)` | school_id | One active subscription per school |
| `INDEX(status, current_period_end)` | status, current_period_end | Find expiring/cancelled subscriptions |

---

## 3. Authentication & Sessions

### 3.1 users

**Purpose:** Authentication identity. One user per email per school.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | Tenant scope |
| email | VARCHAR(255) | NOT NULL | Login identifier |
| encrypted_password | VARCHAR(255) | NOT NULL | Devise bcrypt hash |
| role | VARCHAR(32) | NOT NULL | admin, teacher, student, parent |
| first_name | VARCHAR(100) | NOT NULL | |
| last_name | VARCHAR(100) | NOT NULL | |
| phone | VARCHAR(32) | NULL | Optional contact |
| avatar_url | VARCHAR(512) | NULL | Profile image URL |
| email_verified_at | TIMESTAMPTZ | NULL | Email confirmation timestamp |
| email_deliverable | BOOLEAN | NOT NULL, DEFAULT true | Set false on bounce |
| last_sign_in_at | TIMESTAMPTZ | NULL | Devise trackable |
| last_sign_in_ip | INET | NULL | Devise trackable |
| sign_in_count | INTEGER | NOT NULL, DEFAULT 0 | Devise trackable |
| discarded_at | TIMESTAMPTZ | NULL | Soft delete |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, email)` | school_id, email | Same email allowed at different schools; login lookup |
| `INDEX(school_id, role)` | school_id, role | Filter users by role within tenant |
| `INDEX(school_id, discarded_at) WHERE discarded_at IS NULL` | school_id | Active users per school |
| `GIN(email gin_trgm_ops)` | email | Fuzzy email search |

---

### 3.2 roles

**Purpose:** Custom RBAC roles (future). System roles use `users.role` enum.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NULL, FK → schools(id) | NULL = system role template |
| name | VARCHAR(64) | NOT NULL | Role display name |
| slug | VARCHAR(64) | NOT NULL | Machine-readable identifier |
| permissions | JSONB | NOT NULL, DEFAULT '{}' | `{ "students": ["read","write"], ... }` |
| is_system | BOOLEAN | NOT NULL, DEFAULT false | System roles cannot be deleted |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, slug)` | school_id, slug | Unique role per school |
| `INDEX(school_id) WHERE school_id IS NOT NULL` | school_id | List custom roles per school |

---

### 3.3 user_roles (join)

**Purpose:** Assign custom roles to users (future multi-role support).

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| user_id | UUID | NOT NULL, FK → users(id) | |
| role_id | UUID | NOT NULL, FK → roles(id) | |
| school_id | UUID | NOT NULL, FK → schools(id) | Denormalized for scope |
| created_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(user_id, role_id)` | user_id, role_id | One assignment per user-role pair |
| `INDEX(school_id, user_id)` | school_id, user_id | List roles for user within tenant |

---

### 3.4 refresh_tokens

**Purpose:** JWT refresh token storage with rotation chain.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| user_id | UUID | NOT NULL, FK → users(id) | Token owner |
| school_id | UUID | NOT NULL, FK → schools(id) | Tenant scope |
| token_digest | VARCHAR(255) | NOT NULL, UNIQUE | bcrypt hash of refresh token |
| device_name | VARCHAR(255) | NULL | "Chrome on macOS" |
| ip_address | INET | NULL | Login IP |
| user_agent | TEXT | NULL | Browser identification |
| expires_at | TIMESTAMPTZ | NOT NULL | Token expiry |
| revoked_at | TIMESTAMPTZ | NULL | Set on logout or rotation |
| replaced_by_id | UUID | NULL, FK → refresh_tokens(id) | Rotation chain for reuse detection |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(token_digest)` | token_digest | Fast token lookup on refresh |
| `INDEX(user_id, revoked_at) WHERE revoked_at IS NULL` | user_id | Active tokens per user |
| `INDEX(expires_at) WHERE revoked_at IS NULL` | expires_at | Cleanup expired tokens job |

---

### 3.5 device_sessions

**Purpose:** User-visible device list for "logout all devices" UI.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| user_id | UUID | NOT NULL, FK → users(id) | |
| refresh_token_id | UUID | NOT NULL, FK → refresh_tokens(id), UNIQUE | 1:1 with refresh token |
| school_id | UUID | NOT NULL, FK → schools(id) | Tenant scope |
| device_name | VARCHAR(255) | NOT NULL | Display name |
| ip_address | INET | NULL | |
| last_active_at | TIMESTAMPTZ | NOT NULL | Updated on each refresh |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(user_id, last_active_at DESC)` | user_id | Device list sorted by activity |
| `UNIQUE(refresh_token_id)` | refresh_token_id | One session per token |

---

## 4. Users & Profiles

### 4.1 teachers

**Purpose:** Teacher profile extending user.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| user_id | UUID | NOT NULL, FK → users(id), UNIQUE | 1:1 with user |
| employee_id | VARCHAR(64) | NULL | School-assigned ID |
| department_id | UUID | NULL, FK → departments(id) | |
| hire_date | DATE | NULL | |
| bio | TEXT | NULL | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, user_id)` | school_id, user_id | One teacher profile per user per school |
| `UNIQUE(school_id, employee_id) WHERE employee_id IS NOT NULL` | school_id, employee_id | Unique employee ID per school |
| `INDEX(school_id, department_id)` | school_id, department_id | Teachers by department |

---

### 4.2 students

**Purpose:** Student profile extending user.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| user_id | UUID | NOT NULL, FK → users(id), UNIQUE | 1:1 with user |
| student_code | VARCHAR(64) | NOT NULL | School-assigned student ID |
| date_of_birth | DATE | NULL | PII — consider encryption |
| gender | VARCHAR(16) | NULL | male, female, other |
| address | TEXT | NULL | PII |
| emergency_contact | VARCHAR(255) | NULL | |
| emergency_phone | VARCHAR(32) | NULL | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, user_id)` | school_id, user_id | One student profile per user |
| `UNIQUE(school_id, student_code)` | school_id, student_code | Unique student code per school |
| `GIN((first_name \|\| ' ' \|\| last_name) gin_trgm_ops)` | — | Fuzzy name search via join to users |
| `INDEX(school_id) WHERE discarded_at IS NULL` | school_id | Active students per school |

---

### 4.3 parents

**Purpose:** Parent profile extending user.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| user_id | UUID | NOT NULL, FK → users(id), UNIQUE | 1:1 with user |
| occupation | VARCHAR(128) | NULL | |
| address | TEXT | NULL | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, user_id)` | school_id, user_id | One parent profile per user |
| `INDEX(school_id) WHERE discarded_at IS NULL` | school_id | Active parents per school |

---

### 4.4 parent_students

**Purpose:** Many-to-many link between parents and students.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| parent_id | UUID | NOT NULL, FK → parents(id) | |
| student_id | UUID | NOT NULL, FK → students(id) | |
| school_id | UUID | NOT NULL, FK → schools(id) | Denormalized for scope |
| relationship | VARCHAR(32) | NOT NULL | mother, father, guardian |
| is_primary | BOOLEAN | NOT NULL, DEFAULT false | Primary contact |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(parent_id, student_id)` | parent_id, student_id | One link per parent-student pair |
| `INDEX(school_id, student_id)` | school_id, student_id | Find parents of a student |
| `INDEX(school_id, parent_id)` | school_id, parent_id | Find children of a parent |

---

## 5. Academic Structure

### 5.1 departments

**Purpose:** Organizational units (e.g., Science, Humanities). Supports tree structure.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| name | VARCHAR(128) | NOT NULL | |
| parent_id | UUID | NULL, FK → departments(id) | Self-referential tree |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, name, parent_id)` | school_id, name, parent_id | Unique name within parent |
| `INDEX(school_id, parent_id)` | school_id, parent_id | Tree traversal |

---

### 5.2 academic_years

**Purpose:** School year boundary (e.g., 2025-2026).

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| name | VARCHAR(64) | NOT NULL | "2025-2026" |
| starts_on | DATE | NOT NULL | |
| ends_on | DATE | NOT NULL | |
| status | VARCHAR(32) | NOT NULL, DEFAULT 'upcoming' | upcoming, active, completed |
| is_current | BOOLEAN | NOT NULL, DEFAULT false | Only one current per school |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, name)` | school_id, name | Unique year name per school |
| `UNIQUE(school_id) WHERE is_current = true` | school_id | Enforce one current year |
| `INDEX(school_id, status)` | school_id, status | Filter by status |

---

### 5.3 semesters

**Purpose:** Term within academic year (e.g., Fall, Spring).

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| academic_year_id | UUID | NOT NULL, FK → academic_years(id) | |
| name | VARCHAR(64) | NOT NULL | "Fall 2025" |
| starts_on | DATE | NOT NULL | |
| ends_on | DATE | NOT NULL | |
| is_current | BOOLEAN | NOT NULL, DEFAULT false | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(academic_year_id, name)` | academic_year_id, name | Unique semester per year |
| `INDEX(school_id, academic_year_id)` | school_id, academic_year_id | Semesters by year |

---

### 5.4 classes

**Purpose:** Grade level / cohort (e.g., "Grade 10").

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| academic_year_id | UUID | NOT NULL, FK → academic_years(id) | |
| department_id | UUID | NULL, FK → departments(id) | |
| name | VARCHAR(128) | NOT NULL | "Grade 10" |
| homeroom_teacher_id | UUID | NULL, FK → teachers(id) | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, academic_year_id, name)` | school_id, academic_year_id, name | Unique class per year |
| `INDEX(school_id, academic_year_id)` | school_id, academic_year_id | Classes by year |

---

### 5.5 sections

**Purpose:** Class division (e.g., "10-A", "10-B").

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| class_id | UUID | NOT NULL, FK → classes(id) | |
| name | VARCHAR(64) | NOT NULL | "A", "B" |
| capacity | INTEGER | NOT NULL, DEFAULT 30 | Max students |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(class_id, name)` | class_id, name | Unique section per class |
| `INDEX(school_id, class_id)` | school_id, class_id | Sections by class |

---

### 5.6 subjects

**Purpose:** Course definition (e.g., Mathematics, Physics).

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| department_id | UUID | NULL, FK → departments(id) | |
| name | VARCHAR(128) | NOT NULL | |
| code | VARCHAR(32) | NOT NULL | "MATH-101" |
| credit_hours | DECIMAL(4,1) | NULL | |
| description | TEXT | NULL | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(school_id, code)` | school_id, code | Unique subject code per school |
| `INDEX(school_id, department_id)` | school_id, department_id | Subjects by department |
| `GIN(name gin_trgm_ops)` | name | Fuzzy subject search |

---

### 5.7 subject_assignments

**Purpose:** Maps teacher to subject for a specific class/section.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| teacher_id | UUID | NOT NULL, FK → teachers(id) | |
| subject_id | UUID | NOT NULL, FK → subjects(id) | |
| class_id | UUID | NOT NULL, FK → classes(id) | |
| section_id | UUID | NULL, FK → sections(id) | NULL = all sections |
| academic_year_id | UUID | NOT NULL, FK → academic_years(id) | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(teacher_id, subject_id, class_id, section_id, academic_year_id)` | composite | One assignment per combination |
| `INDEX(school_id, teacher_id)` | school_id, teacher_id | Teacher's assignments |
| `INDEX(school_id, class_id)` | school_id, class_id | Assignments for a class |

---

### 5.8 enrollments

**Purpose:** Student enrollment in class/section for an academic year.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| student_id | UUID | NOT NULL, FK → students(id) | |
| class_id | UUID | NOT NULL, FK → classes(id) | |
| section_id | UUID | NOT NULL, FK → sections(id) | |
| academic_year_id | UUID | NOT NULL, FK → academic_years(id) | |
| status | VARCHAR(32) | NOT NULL, DEFAULT 'active' | active, transferred, graduated, withdrawn |
| enrolled_on | DATE | NOT NULL | |
| created_by_id | UUID | NULL, FK → users(id) | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(student_id, academic_year_id)` | student_id, academic_year_id | One class per student per year |
| `INDEX(school_id, section_id)` | school_id, section_id | Students in a section |
| `INDEX(school_id, class_id, status)` | school_id, class_id, status | Active enrollments per class |

---

## 6. Scheduling & Lessons

### 6.1 schedules

**Purpose:** Timetable entry — when/where a subject is taught.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| section_id | UUID | NOT NULL, FK → sections(id) | |
| subject_id | UUID | NOT NULL, FK → subjects(id) | |
| teacher_id | UUID | NOT NULL, FK → teachers(id) | |
| day_of_week | SMALLINT | NOT NULL, CHECK 0-6 | 0=Sunday, 6=Saturday |
| starts_at | TIME | NOT NULL | |
| ends_at | TIME | NOT NULL | |
| room | VARCHAR(64) | NULL | |
| academic_year_id | UUID | NOT NULL, FK → academic_years(id) | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, section_id, day_of_week)` | school_id, section_id, day_of_week | Daily timetable for section |
| `INDEX(school_id, teacher_id, day_of_week)` | school_id, teacher_id, day_of_week | Teacher's weekly schedule |
| `INDEX(school_id, academic_year_id)` | school_id, academic_year_id | Schedules by year |

---

### 6.2 lessons

**Purpose:** Lesson plan content linked to a schedule slot.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| schedule_id | UUID | NOT NULL, FK → schedules(id) | |
| title | VARCHAR(255) | NOT NULL | |
| content | TEXT | NULL | Lesson plan body |
| lesson_date | DATE | NOT NULL | |
| created_by_id | UUID | NOT NULL, FK → users(id) | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, schedule_id, lesson_date)` | school_id, schedule_id, lesson_date | Lessons by schedule and date |
| `INDEX(school_id, lesson_date)` | school_id, lesson_date | Lessons on a given day |

---

## 7. Academic Operations

### 7.1 attendance_records

**Purpose:** Daily attendance status per student per section.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| student_id | UUID | NOT NULL, FK → students(id) | |
| section_id | UUID | NOT NULL, FK → sections(id) | |
| date | DATE | NOT NULL | |
| status | VARCHAR(16) | NOT NULL | present, absent, late, excused |
| notes | TEXT | NULL | Reason for absence |
| recorded_by_id | UUID | NOT NULL, FK → users(id) | Teacher who recorded |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(student_id, section_id, date)` | student_id, section_id, date | One record per student per day per section |
| `INDEX(school_id, date, section_id)` | school_id, date, section_id | Daily attendance sheet for section |
| `INDEX(school_id, student_id, date DESC)` | school_id, student_id, date | Student attendance history |

**Optimization:** Partition by month when rows exceed 100M.

---

### 7.2 grades

**Purpose:** Assessment scores for students.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| student_id | UUID | NOT NULL, FK → students(id) | |
| subject_id | UUID | NOT NULL, FK → subjects(id) | |
| teacher_id | UUID | NOT NULL, FK → teachers(id) | |
| semester_id | UUID | NOT NULL, FK → semesters(id) | |
| grade_type | VARCHAR(32) | NOT NULL | exam, quiz, homework, project, participation |
| value | DECIMAL(6,2) | NOT NULL | Score achieved |
| max_value | DECIMAL(6,2) | NOT NULL, DEFAULT 100 | Maximum possible score |
| weight | DECIMAL(4,2) | NOT NULL, DEFAULT 1.0 | Weight for GPA calculation |
| comment | TEXT | NULL | Teacher feedback |
| recorded_at | TIMESTAMPTZ | NOT NULL | When grade was entered |
| created_by_id | UUID | NOT NULL, FK → users(id) | |
| updated_by_id | UUID | NULL, FK → users(id) | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, student_id, semester_id)` | school_id, student_id, semester_id | Student gradebook per semester |
| `INDEX(school_id, subject_id, semester_id)` | school_id, subject_id, semester_id | Subject grades per semester |
| `INDEX(school_id, teacher_id)` | school_id, teacher_id | Grades entered by teacher |

---

### 7.3 homework

**Purpose:** Homework assignment created by teacher.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| title | VARCHAR(255) | NOT NULL | |
| description | TEXT | NULL | |
| subject_id | UUID | NOT NULL, FK → subjects(id) | |
| class_id | UUID | NOT NULL, FK → classes(id) | |
| section_id | UUID | NULL, FK → sections(id) | NULL = all sections |
| teacher_id | UUID | NOT NULL, FK → teachers(id) | |
| due_at | TIMESTAMPTZ | NOT NULL | |
| max_score | DECIMAL(6,2) | NULL | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, class_id, due_at)` | school_id, class_id, due_at | Homework for class sorted by due date |
| `INDEX(school_id, teacher_id)` | school_id, teacher_id | Teacher's homework list |

---

### 7.4 assignments

**Purpose:** Per-student homework submission tracking.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| homework_id | UUID | NOT NULL, FK → homework(id) | |
| student_id | UUID | NOT NULL, FK → students(id) | |
| status | VARCHAR(32) | NOT NULL, DEFAULT 'pending' | pending, submitted, graded, late |
| submitted_at | TIMESTAMPTZ | NULL | |
| score | DECIMAL(6,2) | NULL | |
| feedback | TEXT | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `UNIQUE(homework_id, student_id)` | homework_id, student_id | One assignment per student per homework |
| `INDEX(school_id, student_id, status)` | school_id, student_id, status | Student's pending homework |

---

### 7.5 exams

**Purpose:** Scheduled examinations.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| title | VARCHAR(255) | NOT NULL | |
| subject_id | UUID | NOT NULL, FK → subjects(id) | |
| class_id | UUID | NOT NULL, FK → classes(id) | |
| section_id | UUID | NULL, FK → sections(id) | NULL = all sections |
| teacher_id | UUID | NOT NULL, FK → teachers(id) | |
| scheduled_at | TIMESTAMPTZ | NOT NULL | |
| duration_minutes | INTEGER | NOT NULL | |
| max_score | DECIMAL(6,2) | NOT NULL, DEFAULT 100 | |
| room | VARCHAR(64) | NULL | |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, class_id, scheduled_at)` | school_id, class_id, scheduled_at | Upcoming exams for class |
| `INDEX(school_id, teacher_id)` | school_id, teacher_id | Teacher's exams |

---

## 8. Communication

### 8.1 announcements

**Purpose:** School-wide or targeted announcements.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| author_id | UUID | NOT NULL, FK → users(id) | |
| title | VARCHAR(255) | NOT NULL | |
| body | TEXT | NOT NULL | HTML sanitized |
| target_type | VARCHAR(32) | NOT NULL, DEFAULT 'all' | all, role, class, section |
| target_ids | JSONB | NOT NULL, DEFAULT '[]' | UUIDs of target entities |
| published_at | TIMESTAMPTZ | NULL | NULL = draft |
| discarded_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, published_at DESC) WHERE published_at IS NOT NULL` | school_id, published_at | Published announcements feed |
| `INDEX(school_id, target_type)` | school_id, target_type | Filter by target type |

---

### 8.2 notifications

**Purpose:** In-app notifications for users.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| user_id | UUID | NOT NULL, FK → users(id) | Recipient |
| title | VARCHAR(255) | NOT NULL | |
| body | TEXT | NULL | |
| read_at | TIMESTAMPTZ | NULL | NULL = unread |
| notifiable_type | VARCHAR(64) | NULL | Polymorphic source type |
| notifiable_id | UUID | NULL | Polymorphic source ID |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, user_id, read_at) WHERE read_at IS NULL` | school_id, user_id | Unread notifications per user |
| `INDEX(school_id, user_id, created_at DESC)` | school_id, user_id | Notification feed |

---

### 8.3 messages

**Purpose:** Direct user-to-user messaging.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| sender_id | UUID | NOT NULL, FK → users(id) | |
| recipient_id | UUID | NOT NULL, FK → users(id) | |
| body | TEXT | NOT NULL | |
| read_at | TIMESTAMPTZ | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, recipient_id, read_at) WHERE read_at IS NULL` | school_id, recipient_id | Unread messages |
| `INDEX(school_id, sender_id, created_at DESC)` | school_id, sender_id | Sent messages |
| `INDEX(school_id, recipient_id, created_at DESC)` | school_id, recipient_id | Received messages |

---

## 9. Files & Audit

### 9.1 audit_logs

**Purpose:** Compliance audit trail for all significant actions.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| user_id | UUID | NULL, FK → users(id) | NULL for system actions |
| action | VARCHAR(64) | NOT NULL | create, update, delete, login, logout, etc. |
| auditable_type | VARCHAR(64) | NULL | Polymorphic record type |
| auditable_id | UUID | NULL | Polymorphic record ID |
| metadata | JSONB | NOT NULL, DEFAULT '{}' | Changed fields, IP, user agent |
| ip_address | INET | NULL | |
| created_at | TIMESTAMPTZ | NOT NULL | Immutable — no updated_at |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, created_at DESC)` | school_id, created_at | Compliance queries by date |
| `INDEX(school_id, user_id, created_at DESC)` | school_id, user_id | User activity history |
| `INDEX(school_id, auditable_type, auditable_id)` | school_id, auditable_type, auditable_id | Record change history |

**Optimization:** Partition by month when rows exceed 100M.

---

### 9.2 reports

**Purpose:** Async-generated report metadata.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | |
| school_id | UUID | NOT NULL, FK → schools(id) | |
| requested_by_id | UUID | NOT NULL, FK → users(id) | |
| report_type | VARCHAR(64) | NOT NULL | attendance, grades, enrollment, custom |
| parameters | JSONB | NOT NULL, DEFAULT '{}' | Filter criteria |
| status | VARCHAR(32) | NOT NULL, DEFAULT 'pending' | pending, processing, completed, failed |
| file_url | VARCHAR(512) | NULL | R2 signed URL when completed |
| error_message | TEXT | NULL | |
| completed_at | TIMESTAMPTZ | NULL | |
| expires_at | TIMESTAMPTZ | NULL | Auto-delete after 24 hours |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Indexes:**

| Index | Columns | Why |
|-------|---------|-----|
| `INDEX(school_id, requested_by_id, status)` | school_id, requested_by_id | User's report requests |
| `INDEX(status) WHERE status = 'pending'` | status | Job pickup for pending reports |

---

## 10. Active Storage

Rails Active Storage default tables. `school_id` is not on these tables — tenant context comes from the attached record's `school_id`.

### 10.1 active_storage_blobs

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| key | VARCHAR | Unique storage key |
| filename | VARCHAR | Original filename |
| content_type | VARCHAR | MIME type (verified by Marcel) |
| metadata | TEXT | JSON metadata |
| service_name | VARCHAR | Storage service (r2, s3) |
| byte_size | BIGINT | File size |
| checksum | VARCHAR | SHA-256 for deduplication |
| created_at | TIMESTAMPTZ | |

**Indexes:** `UNIQUE(key)`

### 10.2 active_storage_attachments

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| name | VARCHAR | Attachment name on record |
| record_type | VARCHAR | Polymorphic (Homework, Announcement, etc.) |
| record_id | UUID | Polymorphic record ID |
| blob_id | UUID | FK → active_storage_blobs |

**Indexes:** `UNIQUE(record_type, record_id, name, blob_id)`, `INDEX(blob_id)`

### 10.3 active_storage_variant_records

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| blob_id | UUID | FK → active_storage_blobs |
| variation_digest | VARCHAR | Variant identifier |

**Indexes:** `UNIQUE(blob_id, variation_digest)`

---

## 11. Index Summary

### Rules

1. **Every tenant-owned table** has `school_id` as leading column in composite indexes
2. **Every FK column** has an index (PostgreSQL does not auto-index FKs)
3. **Soft-deleted tables** use partial indexes `WHERE discarded_at IS NULL`
4. **Search columns** use GIN/trgm indexes
5. **High-volume tables** (`attendance_records`, `audit_logs`) are partition candidates

### Performance Maintenance

| Practice | Frequency |
|----------|-----------|
| `VACUUM ANALYZE` | Automated (managed PostgreSQL) |
| Index usage review | Monthly via `pg_stat_user_indexes` |
| Slow query log | Continuous (>50ms logged in staging) |
| Connection pool tuning | Quarterly review of PgBouncer stats |
| Partition evaluation | When table exceeds 50M rows |

---

**See also:** [SAD.md](./SAD.md) · [api-reference.md](./api-reference.md) · [operations.md](./operations.md)

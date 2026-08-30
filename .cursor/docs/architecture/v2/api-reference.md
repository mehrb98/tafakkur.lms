# REST API Reference — Tafakkur LMS v2.0

> **Master document:** [SAD.md §10](./SAD.md#10-rest-api-design)

**Base URL:** `https://api.tafakkur.com/api/v1`  
**Content-Type:** `application/json`  
**Authentication:** `Authorization: Bearer <access_token>` (except public endpoints)

---

## Table of Contents

1. [Global Conventions](#1-global-conventions)
2. [Authentication](#2-authentication)
3. [School & Settings](#3-school--settings)
4. [Teachers](#4-teachers)
5. [Students](#5-students)
6. [Parents](#6-parents)
7. [Departments](#7-departments)
8. [Academic Years & Semesters](#8-academic-years--semesters)
9. [Classes & Sections](#9-classes--sections)
10. [Subjects](#10-subjects)
11. [Schedules & Lessons](#11-schedules--lessons)
12. [Attendance](#12-attendance)
13. [Grades](#13-grades)
14. [Homework & Assignments](#14-homework--assignments)
15. [Exams](#15-exams)
16. [Announcements](#16-announcements)
17. [Notifications](#17-notifications)
18. [Messages](#18-messages)
19. [Files](#19-files)
20. [Reports](#20-reports)
21. [Analytics](#21-analytics)
22. [Health](#22-health)

---

## 1. Global Conventions

### 1.1 Response Envelope

**Success:**

```json
{
    "data": {},
    "meta": {}
}
```

**Error:**

```json
{
    "error": {
        "code": "validation_error",
        "message": "Record could not be saved",
        "details": [
            { "field": "email", "message": "has already been taken" }
        ]
    }
}
```

### 1.2 Pagination

| Parameter | Default | Max |
|-----------|---------|-----|
| `page` | 1 | — |
| `limit` | 25 | 100 |

```json
{
    "data": [],
    "meta": {
        "page": 1,
        "limit": 25,
        "total": 240,
        "total_pages": 10
    }
}
```

### 1.3 Filtering, Sorting, Searching

- **Filter:** `?class_id=uuid&status=active&role=teacher`
- **Sort:** `?sort=last_name&order=asc` (whitelisted fields per resource)
- **Search:** `?q=john` (pg_trgm on name, email, student_code)

### 1.4 Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 422 | Validation Error |
| 429 | Rate Limited |
| 500 | Internal Server Error |

### 1.5 Common Error Responses

**401 Unauthorized:**

```json
{
    "error": {
        "code": "unauthorized",
        "message": "Invalid or expired token",
        "details": []
    }
}
```

**403 Forbidden:**

```json
{
    "error": {
        "code": "forbidden",
        "message": "You are not authorized to perform this action",
        "details": []
    }
}
```

**404 Not Found:**

```json
{
    "error": {
        "code": "not_found",
        "message": "Record not found",
        "details": []
    }
}
```

**422 Validation Error:**

```json
{
    "error": {
        "code": "validation_error",
        "message": "Record could not be saved",
        "details": [
            { "field": "email", "message": "has already been taken" },
            { "field": "first_name", "message": "can't be blank" }
        ]
    }
}
```

**429 Rate Limited:**

```json
{
    "error": {
        "code": "rate_limit_exceeded",
        "message": "Too many requests. Retry after 60 seconds.",
        "details": []
    }
}
```

---

## 2. Authentication

### POST /auth/login

**Purpose:** Authenticate user and issue token pair.  
**Auth:** Public  
**Authorization:** None

**Request:**

```json
{
    "email": "admin@school.com",
    "password": "SecurePass123!",
    "remember_me": true
}
```

**Validation:**

| Field | Rules |
|-------|-------|
| email | Required, valid email format |
| password | Required |
| remember_me | Optional boolean |

**Response (201):**

```json
{
    "data": {
        "access_token": "eyJhbGciOiJIUzI1NiJ9...",
        "expires_in": 900,
        "user": {
            "id": "018f3a2b-7c4d-7000-8000-000000000001",
            "email": "admin@school.com",
            "first_name": "John",
            "last_name": "Doe",
            "role": "admin",
            "school_id": "018f3a2b-7c4d-7000-8000-000000000010"
        }
    }
}
```

**Set-Cookie:** `refresh_token=<token>; HttpOnly; Secure; SameSite=Lax; Path=/api/v1/auth; Max-Age=2592000`

**Errors:** 401 (invalid credentials), 422 (validation), 429 (rate limited)

---

### POST /auth/refresh

**Purpose:** Rotate refresh token and issue new access token.  
**Auth:** Refresh cookie  
**Authorization:** None

**Request:** Empty body; refresh token sent via cookie.

**Response (200):**

```json
{
    "data": {
        "access_token": "eyJhbGciOiJIUzI1NiJ9...",
        "expires_in": 900
    }
}
```

**Errors:** 401 (invalid/expired/revoked refresh token — if revoked token reused, all sessions revoked)

---

### POST /auth/logout

**Purpose:** Revoke current device session.  
**Auth:** Bearer  
**Authorization:** Any authenticated user

**Response (204):** No content.

---

### DELETE /auth/sessions

**Purpose:** Logout all devices — revoke all refresh tokens.  
**Auth:** Bearer  
**Authorization:** Any authenticated user

**Response (204):** No content.

---

### GET /auth/sessions

**Purpose:** List active device sessions.  
**Auth:** Bearer  
**Authorization:** Any authenticated user

**Response (200):**

```json
{
    "data": [
        {
            "id": "018f3a2b-7c4d-7000-8000-000000000100",
            "device_name": "Chrome on macOS",
            "ip_address": "192.168.1.1",
            "last_active_at": "2026-07-09T10:30:00Z",
            "is_current": true
        }
    ]
}
```

---

### DELETE /auth/sessions/:id

**Purpose:** Revoke a specific device session.  
**Auth:** Bearer  
**Authorization:** Session owner

**Response (204):** No content.  
**Errors:** 404 (session not found or not owned)

---

### POST /auth/password

**Purpose:** Request password reset email.  
**Auth:** Public

**Request:**

```json
{
    "email": "user@school.com"
}
```

**Response (200):**

```json
{
    "data": {
        "message": "If the email exists, a reset link has been sent."
    }
}
```

Always returns 200 to prevent email enumeration.

---

### PATCH /auth/password

**Purpose:** Reset password with token.  
**Auth:** Reset token (query param or body)

**Request:**

```json
{
    "token": "reset-token-from-email",
    "password": "NewSecurePass123!",
    "password_confirmation": "NewSecurePass123!"
}
```

**Validation:**

| Field | Rules |
|-------|-------|
| password | Min 12 chars, mixed case + number, not in breach database |
| password_confirmation | Must match password |

**Response (200):**

```json
{
    "data": {
        "message": "Password updated successfully. All sessions revoked."
    }
}
```

**Errors:** 422 (invalid token or weak password)

---

### GET /auth/confirmation

**Purpose:** Verify email address.  
**Auth:** Confirmation token (query param)

**Request:** `GET /auth/confirmation?token=abc123`

**Response (200):**

```json
{
    "data": {
        "message": "Email verified successfully."
    }
}
```

---

## 3. School & Settings

### GET /school

**Purpose:** Get current school details.  
**Auth:** Bearer  
**Authorization:** Any authenticated user

**Response (200):**

```json
{
    "data": {
        "id": "018f3a2b-7c4d-7000-8000-000000000010",
        "name": "Tafakkur International School",
        "slug": "tafakkur-intl",
        "timezone": "Asia/Tashkent",
        "locale": "uz",
        "settings": {
            "branding": { "logo_url": "https://...", "primary_color": "#1a56db" },
            "features": { "messaging": true, "analytics": true }
        },
        "subscription_status": "active"
    }
}
```

---

### PATCH /school

**Purpose:** Update school details.  
**Auth:** Bearer  
**Authorization:** admin

**Request:**

```json
{
    "school": {
        "name": "Updated School Name",
        "timezone": "Asia/Tashkent",
        "locale": "en"
    }
}
```

**Response (200):** Updated school object.

**Errors:** 403 (non-admin), 422 (validation)

---

### GET /settings

**Purpose:** Get school settings.  
**Auth:** Bearer  
**Authorization:** admin

**Response (200):**

```json
{
    "data": {
        "branding": { "logo_url": "https://...", "primary_color": "#1a56db" },
        "features": { "messaging": true, "analytics": true },
        "limits": { "max_file_size_mb": 25, "max_students": 5000 }
    }
}
```

---

### PATCH /settings

**Purpose:** Update school settings.  
**Auth:** Bearer  
**Authorization:** admin

**Request:**

```json
{
    "settings": {
        "branding": { "primary_color": "#2563eb" },
        "features": { "messaging": false }
    }
}
```

**Response (200):** Updated settings object.

---

## 4. Teachers

### GET /teachers

**Purpose:** List teachers.  
**Auth:** Bearer  
**Authorization:** admin

**Query params:** `page`, `limit`, `q`, `sort`, `order`, `department_id`

**Response (200):**

```json
{
    "data": [
        {
            "id": "018f3a2b-7c4d-7000-8000-000000000020",
            "user_id": "018f3a2b-7c4d-7000-8000-000000000002",
            "first_name": "Sarah",
            "last_name": "Johnson",
            "email": "sarah@school.com",
            "employee_id": "EMP-001",
            "department": { "id": "...", "name": "Science" },
            "hire_date": "2024-09-01"
        }
    ],
    "meta": { "page": 1, "limit": 25, "total": 45, "total_pages": 2 }
}
```

---

### POST /teachers

**Purpose:** Create teacher account.  
**Auth:** Bearer  
**Authorization:** admin

**Request:**

```json
{
    "teacher": {
        "first_name": "Sarah",
        "last_name": "Johnson",
        "email": "sarah@school.com",
        "employee_id": "EMP-002",
        "department_id": "018f3a2b-7c4d-7000-8000-000000000030",
        "hire_date": "2026-09-01"
    }
}
```

**Validation:**

| Field | Rules |
|-------|-------|
| first_name | Required, max 100 chars |
| last_name | Required, max 100 chars |
| email | Required, unique per school, valid format |
| employee_id | Optional, unique per school |
| department_id | Must belong to same school |

**Response (201):** Created teacher object. Welcome email enqueued.

**Errors:** 422 (duplicate email/employee_id)

---

### GET /teachers/:id

**Purpose:** Get teacher details.  
**Auth:** Bearer  
**Authorization:** admin, self (teacher)

**Response (200):** Teacher object with assignments.

---

### PATCH /teachers/:id

**Purpose:** Update teacher.  
**Auth:** Bearer  
**Authorization:** admin (all fields); self (bio only)

**Response (200):** Updated teacher object.

---

### DELETE /teachers/:id

**Purpose:** Soft-delete teacher.  
**Auth:** Bearer  
**Authorization:** admin

**Response (204):** No content.

---

## 5. Students

### GET /students

**Purpose:** List students.  
**Auth:** Bearer  
**Authorization:** admin (all); teacher (assigned classes only)

**Query params:** `page`, `limit`, `q`, `sort`, `order`, `class_id`, `section_id`, `status`

**Response (200):**

```json
{
    "data": [
        {
            "id": "018f3a2b-7c4d-7000-8000-000000000040",
            "user_id": "018f3a2b-7c4d-7000-8000-000000000004",
            "first_name": "Ali",
            "last_name": "Karimov",
            "email": "ali@student.school.com",
            "student_code": "STU-2026-001",
            "enrollment": {
                "class": { "id": "...", "name": "Grade 10" },
                "section": { "id": "...", "name": "A" }
            }
        }
    ],
    "meta": { "page": 1, "limit": 25, "total": 320, "total_pages": 13 }
}
```

---

### POST /students

**Purpose:** Create student and optionally enroll.  
**Auth:** Bearer  
**Authorization:** admin

**Request:**

```json
{
    "student": {
        "first_name": "Ali",
        "last_name": "Karimov",
        "email": "ali@student.school.com",
        "student_code": "STU-2026-001",
        "date_of_birth": "2010-05-15",
        "class_id": "018f3a2b-7c4d-7000-8000-000000000050",
        "section_id": "018f3a2b-7c4d-7000-8000-000000000051"
    }
}
```

**Validation:**

| Field | Rules |
|-------|-------|
| first_name | Required, max 100 chars |
| last_name | Required, max 100 chars |
| email | Required, unique per school |
| student_code | Required, unique per school |
| class_id | Must belong to current academic year |
| section_id | Must belong to class_id |

**Response (201):** Created student with enrollment.

---

### GET /students/:id

**Purpose:** Get student details.  
**Auth:** Bearer  
**Authorization:** admin, assigned teacher, self (student), parent of student

**Response (200):** Student object with enrollment, parents.

---

### PATCH /students/:id

**Purpose:** Update student.  
**Auth:** Bearer  
**Authorization:** admin

**Response (200):** Updated student object.

---

### DELETE /students/:id

**Purpose:** Soft-delete student.  
**Auth:** Bearer  
**Authorization:** admin

**Response (204):** No content.

---

### POST /students/:id/enroll

**Purpose:** Enroll student in class/section.  
**Auth:** Bearer  
**Authorization:** admin

**Request:**

```json
{
    "enrollment": {
        "class_id": "018f3a2b-7c4d-7000-8000-000000000050",
        "section_id": "018f3a2b-7c4d-7000-8000-000000000051",
        "academic_year_id": "018f3a2b-7c4d-7000-8000-000000000060"
    }
}
```

**Validation:** One enrollment per student per academic year.

**Response (201):** Enrollment object.

**Errors:** 422 (already enrolled, section at capacity)

---

## 6. Parents

### GET /parents

**Purpose:** List parents.  
**Auth:** Bearer  
**Authorization:** admin

**Response (200):** Paginated parent list with children count.

---

### POST /parents

**Purpose:** Create parent account.  
**Auth:** Bearer  
**Authorization:** admin

**Request:**

```json
{
    "parent": {
        "first_name": "Bobur",
        "last_name": "Karimov",
        "email": "bobur@parent.com",
        "phone": "+998901234567",
        "student_ids": ["018f3a2b-7c4d-7000-8000-000000000040"],
        "relationship": "father"
    }
}
```

**Response (201):** Created parent with linked children.

---

### POST /parents/:id/link_student

**Purpose:** Link parent to additional student.  
**Auth:** Bearer  
**Authorization:** admin

**Request:**

```json
{
    "student_id": "018f3a2b-7c4d-7000-8000-000000000041",
    "relationship": "father",
    "is_primary": true
}
```

**Response (201):** Parent-student link object.

---

### GET /parents/:id/children

**Purpose:** List parent's linked children.  
**Auth:** Bearer  
**Authorization:** admin, self (parent)

**Response (200):**

```json
{
    "data": [
        {
            "id": "018f3a2b-7c4d-7000-8000-000000000040",
            "first_name": "Ali",
            "last_name": "Karimov",
            "student_code": "STU-2026-001",
            "relationship": "father",
            "enrollment": {
                "class": { "name": "Grade 10" },
                "section": { "name": "A" }
            }
        }
    ]
}
```

---

## 7. Departments

### GET /departments

**Auth:** Bearer | **Authorization:** admin, teacher (read)

### POST /departments

**Auth:** Bearer | **Authorization:** admin

**Request:**

```json
{
    "department": {
        "name": "Science",
        "parent_id": null
    }
}
```

### GET /departments/:id | PATCH /departments/:id | DELETE /departments/:id

Standard CRUD. Admin only for write operations.

---

## 8. Academic Years & Semesters

### GET /academic_years

**Auth:** Bearer | **Authorization:** admin, teacher (read)

### POST /academic_years

**Auth:** Bearer | **Authorization:** admin

**Request:**

```json
{
    "academic_year": {
        "name": "2026-2027",
        "starts_on": "2026-09-01",
        "ends_on": "2027-06-30",
        "is_current": true
    }
}
```

**Validation:** Only one `is_current = true` per school.

### GET /academic_years/:id/semesters

**Auth:** Bearer | **Authorization:** admin, teacher (read)

### POST /semesters

**Auth:** Bearer | **Authorization:** admin

**Request:**

```json
{
    "semester": {
        "academic_year_id": "018f3a2b-7c4d-7000-8000-000000000060",
        "name": "Fall 2026",
        "starts_on": "2026-09-01",
        "ends_on": "2026-12-20"
    }
}
```

---

## 9. Classes & Sections

### GET /classes

**Auth:** Bearer | **Authorization:** admin (all); teacher (assigned)

**Query params:** `academic_year_id`, `page`, `limit`

### POST /classes

**Auth:** Bearer | **Authorization:** admin

**Request:**

```json
{
    "class": {
        "name": "Grade 10",
        "academic_year_id": "018f3a2b-7c4d-7000-8000-000000000060",
        "department_id": "018f3a2b-7c4d-7000-8000-000000000030",
        "homeroom_teacher_id": "018f3a2b-7c4d-7000-8000-000000000020"
    }
}
```

### GET /classes/:id/sections

**Auth:** Bearer | **Authorization:** admin, teacher (read)

### POST /sections

**Auth:** Bearer | **Authorization:** admin

**Request:**

```json
{
    "section": {
        "class_id": "018f3a2b-7c4d-7000-8000-000000000050",
        "name": "A",
        "capacity": 30
    }
}
```

Standard GET/PATCH/DELETE for `/classes/:id` and `/sections/:id`.

---

## 10. Subjects

### GET /subjects

**Auth:** Bearer | **Authorization:** admin (all); teacher (assigned, read)

### POST /subjects

**Auth:** Bearer | **Authorization:** admin

**Request:**

```json
{
    "subject": {
        "name": "Mathematics",
        "code": "MATH-101",
        "department_id": "018f3a2b-7c4d-7000-8000-000000000030",
        "credit_hours": 4.0
    }
}
```

**Validation:** `code` unique per school.

Standard GET/PATCH/DELETE for `/subjects/:id`.

---

## 11. Schedules & Lessons

### GET /schedules

**Auth:** Bearer | **Authorization:** Scoped by role

**Query params:** `section_id`, `teacher_id`, `day_of_week`, `academic_year_id`

### GET /schedules/me

**Purpose:** Current user's timetable.  
**Auth:** Bearer  
**Authorization:** student (own section), teacher (own assignments)

**Response (200):**

```json
{
    "data": [
        {
            "id": "...",
            "day_of_week": 1,
            "starts_at": "08:00",
            "ends_at": "08:45",
            "subject": { "name": "Mathematics", "code": "MATH-101" },
            "teacher": { "first_name": "Sarah", "last_name": "Johnson" },
            "section": { "name": "A", "class": { "name": "Grade 10" } },
            "room": "Room 201"
        }
    ]
}
```

### POST /schedules

**Auth:** Bearer | **Authorization:** admin

### GET /lessons | POST /lessons | GET /lessons/:id | PATCH /lessons/:id

**Auth:** Bearer | **Authorization:** teacher (write scoped), admin (all)

---

## 12. Attendance

### GET /attendance_records

**Auth:** Bearer  
**Authorization:** admin (all); teacher (assigned sections); student (self); parent (children)

**Query params:** `section_id`, `student_id`, `date`, `date_from`, `date_to`, `status`

**Response (200):**

```json
{
    "data": [
        {
            "id": "...",
            "student": { "id": "...", "first_name": "Ali", "last_name": "Karimov" },
            "date": "2026-07-09",
            "status": "present",
            "notes": null,
            "recorded_by": { "first_name": "Sarah", "last_name": "Johnson" }
        }
    ],
    "meta": { "page": 1, "limit": 25, "total": 30, "total_pages": 2 }
}
```

---

### POST /attendance_records/bulk

**Purpose:** Record attendance for entire section on a date.  
**Auth:** Bearer  
**Authorization:** teacher (assigned section), admin

**Request:**

```json
{
    "section_id": "018f3a2b-7c4d-7000-8000-000000000051",
    "date": "2026-07-09",
    "records": [
        { "student_id": "018f3a2b-7c4d-7000-8000-000000000040", "status": "present" },
        { "student_id": "018f3a2b-7c4d-7000-8000-000000000041", "status": "absent", "notes": "Sick" },
        { "student_id": "018f3a2b-7c4d-7000-8000-000000000042", "status": "late" }
    ]
}
```

**Validation:**

| Field | Rules |
|-------|-------|
| section_id | Required, must be assigned to teacher |
| date | Required, valid date, not future |
| records | Required array, min 1 item |
| records[].status | One of: present, absent, late, excused |
| records[].student_id | Must be enrolled in section |

**Response (200):**

```json
{
    "data": {
        "summary": {
            "total": 30,
            "present": 27,
            "absent": 2,
            "late": 1,
            "excused": 0
        },
        "records": []
    }
}
```

Side effect: `SendAttendanceAlertJob` enqueued for absent students.

---

### PATCH /attendance_records/:id

**Auth:** Bearer | **Authorization:** teacher (own records), admin

**Request:**

```json
{
    "attendance_record": {
        "status": "excused",
        "notes": "Doctor appointment"
    }
}
```

---

## 13. Grades

### GET /grades

**Auth:** Bearer  
**Authorization:** admin (all); teacher (own subjects); student (self); parent (children)

**Query params:** `student_id`, `subject_id`, `semester_id`, `grade_type`, `page`, `limit`

---

### POST /grades

**Purpose:** Create a grade.  
**Auth:** Bearer  
**Authorization:** teacher (assigned subject), admin

**Request:**

```json
{
    "grade": {
        "student_id": "018f3a2b-7c4d-7000-8000-000000000040",
        "subject_id": "018f3a2b-7c4d-7000-8000-000000000070",
        "semester_id": "018f3a2b-7c4d-7000-8000-000000000061",
        "grade_type": "exam",
        "value": 85.5,
        "max_value": 100,
        "weight": 1.0,
        "comment": "Good work on algebra section"
    }
}
```

**Validation:**

| Field | Rules |
|-------|-------|
| student_id | Required, enrolled in teacher's class |
| subject_id | Required, assigned to teacher |
| value | Required, 0 ≤ value ≤ max_value |
| grade_type | One of: exam, quiz, homework, project, participation |

**Response (201):**

```json
{
    "data": {
        "id": "...",
        "student": { "first_name": "Ali", "last_name": "Karimov" },
        "subject": { "name": "Mathematics" },
        "grade_type": "exam",
        "value": 85.5,
        "max_value": 100,
        "recorded_at": "2026-07-09T14:30:00Z"
    }
}
```

Side effect: `SendGradeNotificationJob` enqueued.

---

### PATCH /grades/:id

**Auth:** Bearer | **Authorization:** teacher (own grades), admin

### DELETE /grades/:id

**Auth:** Bearer | **Authorization:** admin

---

## 14. Homework & Assignments

### GET /homework

**Auth:** Bearer | **Authorization:** admin (all); teacher (own); student/parent (scoped, read)

**Query params:** `class_id`, `subject_id`, `teacher_id`, `due_before`, `due_after`

### POST /homework

**Auth:** Bearer | **Authorization:** teacher (assigned subject), admin

**Request:**

```json
{
    "homework": {
        "title": "Chapter 5 Exercises",
        "description": "Complete exercises 1-20",
        "subject_id": "018f3a2b-7c4d-7000-8000-000000000070",
        "class_id": "018f3a2b-7c4d-7000-8000-000000000050",
        "section_id": "018f3a2b-7c4d-7000-8000-000000000051",
        "due_at": "2026-07-15T23:59:00Z",
        "max_score": 100
    }
}
```

Side effect: Creates `assignments` for each enrolled student.

### GET /assignments

**Auth:** Bearer | **Authorization:** Scoped by role

**Query params:** `homework_id`, `student_id`, `status`

### PATCH /assignments/:id

**Purpose:** Submit homework (student) or grade submission (teacher).

**Student submit:**

```json
{
    "assignment": {
        "status": "submitted"
    }
}
```

**Teacher grade:**

```json
{
    "assignment": {
        "status": "graded",
        "score": 92,
        "feedback": "Excellent work"
    }
}
```

---

## 15. Exams

### GET /exams

**Auth:** Bearer | **Authorization:** Scoped by role

**Query params:** `class_id`, `subject_id`, `scheduled_after`, `scheduled_before`

### POST /exams

**Auth:** Bearer | **Authorization:** teacher (assigned), admin

**Request:**

```json
{
    "exam": {
        "title": "Midterm Mathematics",
        "subject_id": "018f3a2b-7c4d-7000-8000-000000000070",
        "class_id": "018f3a2b-7c4d-7000-8000-000000000050",
        "section_id": "018f3a2b-7c4d-7000-8000-000000000051",
        "scheduled_at": "2026-07-20T09:00:00Z",
        "duration_minutes": 90,
        "max_score": 100,
        "room": "Room 201"
    }
}
```

Standard GET/PATCH/DELETE for `/exams/:id`.

---

## 16. Announcements

### GET /announcements

**Auth:** Bearer | **Authorization:** All roles (filtered by target)

**Response (200):** Paginated announcements matching user's role/class.

### POST /announcements

**Auth:** Bearer | **Authorization:** admin, teacher

**Request:**

```json
{
    "announcement": {
        "title": "Parent-Teacher Meeting",
        "body": "<p>Meeting scheduled for July 15th at 3 PM.</p>",
        "target_type": "class",
        "target_ids": ["018f3a2b-7c4d-7000-8000-000000000050"],
        "published_at": "2026-07-09T10:00:00Z"
    }
}
```

**Validation:**

| Field | Rules |
|-------|-------|
| title | Required, max 255 chars |
| body | Required, HTML sanitized |
| target_type | One of: all, role, class, section |
| target_ids | Required if target_type != all |

Side effect: `PublishAnnouncementJob` fan-out notifications.

### GET /announcements/:id | PATCH /announcements/:id | DELETE /announcements/:id

Standard CRUD. Author or admin for write.

---

## 17. Notifications

### GET /notifications

**Auth:** Bearer | **Authorization:** Current user only

**Query params:** `read` (true/false), `page`, `limit`

**Response (200):**

```json
{
    "data": [
        {
            "id": "...",
            "title": "New grade posted",
            "body": "You received 85.5 in Mathematics",
            "read_at": null,
            "created_at": "2026-07-09T14:30:00Z"
        }
    ],
    "meta": { "page": 1, "limit": 25, "total": 5, "total_pages": 1, "unread_count": 3 }
}
```

### PATCH /notifications/:id/read

**Auth:** Bearer | **Authorization:** Notification owner

**Response (200):** Updated notification with `read_at` set.

### PATCH /notifications/read_all

**Auth:** Bearer | **Authorization:** Current user

**Response (200):** `{ "data": { "marked_read": 3 } }`

---

## 18. Messages

### GET /messages

**Auth:** Bearer | **Authorization:** Sender or recipient

**Query params:** `conversation_with` (user_id), `page`, `limit`

### POST /messages

**Auth:** Bearer | **Authorization:** Any authenticated user (if messaging enabled)

**Request:**

```json
{
    "message": {
        "recipient_id": "018f3a2b-7c4d-7000-8000-000000000002",
        "body": "Could we schedule a meeting?"
    }
}
```

**Validation:** Recipient must be in same school. Messaging must be enabled in school settings.

### PATCH /messages/:id/read

**Auth:** Bearer | **Authorization:** Recipient

---

## 19. Files

### POST /files/presign

**Purpose:** Get presigned URL for direct upload.  
**Auth:** Bearer | **Authorization:** Any authenticated user

**Request:**

```json
{
    "filename": "homework-ch5.pdf",
    "content_type": "application/pdf",
    "byte_size": 1048576
}
```

**Validation:**

| Field | Rules |
|-------|-------|
| filename | Required, sanitized |
| content_type | Must be in allowed MIME list |
| byte_size | Must be ≤ school max file size (default 25 MB) |

**Response (200):**

```json
{
    "data": {
        "blob_id": "018f3a2b-7c4d-7000-8000-000000000200",
        "upload_url": "https://r2.example.com/presigned-put-url",
        "headers": {
            "Content-Type": "application/pdf"
        }
    }
}
```

---

### POST /files

**Purpose:** Attach uploaded blob to a record.  
**Auth:** Bearer | **Authorization:** Policy check on target record

**Request:**

```json
{
    "blob_id": "018f3a2b-7c4d-7000-8000-000000000200",
    "attach_to": {
        "type": "Homework",
        "id": "018f3a2b-7c4d-7000-8000-000000000080"
    }
}
```

**Response (201):** File metadata. `ProcessFileUploadJob` enqueued for virus scan.

---

### GET /files/:id

**Purpose:** Get signed download URL.  
**Auth:** Bearer | **Authorization:** Policy check on attached record

**Response (200):**

```json
{
    "data": {
        "id": "...",
        "filename": "homework-ch5.pdf",
        "content_type": "application/pdf",
        "byte_size": 1048576,
        "download_url": "https://r2.example.com/signed-get-url",
        "expires_at": "2026-07-09T14:35:00Z"
    }
}
```

---

## 20. Reports

### POST /reports

**Purpose:** Request async report generation.  
**Auth:** Bearer | **Authorization:** admin, teacher

**Request:**

```json
{
    "report": {
        "report_type": "attendance",
        "parameters": {
            "section_id": "018f3a2b-7c4d-7000-8000-000000000051",
            "date_from": "2026-09-01",
            "date_to": "2026-12-31",
            "format": "pdf"
        }
    }
}
```

**Response (202):**

```json
{
    "data": {
        "id": "...",
        "report_type": "attendance",
        "status": "pending",
        "created_at": "2026-07-09T15:00:00Z"
    }
}
```

### GET /reports/:id

**Auth:** Bearer | **Authorization:** Requesting user

**Response (200) — completed:**

```json
{
    "data": {
        "id": "...",
        "status": "completed",
        "file_url": "https://r2.example.com/signed-report-url",
        "expires_at": "2026-07-10T15:00:00Z",
        "completed_at": "2026-07-09T15:02:30Z"
    }
}
```

---

## 21. Analytics

### GET /analytics/overview

**Auth:** Bearer | **Authorization:** admin

**Response (200):**

```json
{
    "data": {
        "total_students": 320,
        "total_teachers": 45,
        "total_classes": 12,
        "attendance_rate": 94.5,
        "average_grade": 78.2,
        "active_enrollments": 315
    }
}
```

Cached in Redis (`analytics:overview:{school_id}`, TTL 5 min).

### GET /analytics/teacher

**Auth:** Bearer | **Authorization:** teacher (self)

**Response (200):** Classes taught, students count, average grades, attendance rates.

### GET /analytics/student

**Auth:** Bearer | **Authorization:** student (self)

**Response (200):** GPA, attendance rate, subject averages, upcoming homework/exams.

### GET /analytics/parent

**Auth:** Bearer | **Authorization:** parent (self)

**Query params:** `student_id` (child)

**Response (200):** Child's GPA, attendance, recent grades.

---

## 22. Health

### GET /health

**Purpose:** Liveness probe for load balancer.  
**Auth:** Public

**Response (200):**

```json
{
    "status": "ok",
    "timestamp": "2026-07-09T15:00:00Z"
}
```

### GET /health/ready

**Purpose:** Readiness probe — checks DB and Redis connectivity.  
**Auth:** Internal only (not exposed via public ALB)

**Response (200):**

```json
{
    "status": "ready",
    "checks": {
        "database": "ok",
        "redis": "ok"
    }
}
```

**Response (503) — not ready:**

```json
{
    "status": "not_ready",
    "checks": {
        "database": "ok",
        "redis": "error"
    }
}
```

---

**See also:** [SAD.md](./SAD.md) · [database-schema.md](./database-schema.md) · [operations.md](./operations.md)

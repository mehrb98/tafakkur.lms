# System Design


## Backend Flow


Request

↓

Rails Router

↓

Controller

↓

Authentication

↓

Pundit Authorization

↓

Interactor

↓

Active Record

↓

PostgreSQL

↓

Jbuilder Response


# Frontend Flow


User Action

↓

Component

↓

Custom Hook

↓

Service Layer

↓

Wretch Client

↓

Rails API


# Domain Boundaries


## Identity Domain

Handles:

- Users
- Roles
- Permissions
- Authentication


## School Domain

Handles:

- Schools
- Departments
- Classes


## Academic Domain

Handles:

- Subjects
- Grades
- Exams
- Attendance


## Communication Domain

Handles:

- Messages
- Notifications
- Emails


## Reporting Domain

Handles:

- Analytics
- Reports


# Scalability Strategy


Initial:

Monolith architecture


Future:

Modular monolith


Possible extraction:

- Notification service
- Reporting service
- File service


# Deployment Model


Frontend:

Vercel or container


Backend:

Docker container


Database:

Managed PostgreSQL


Cache:

Managed Redis


Storage:

S3 compatible storage
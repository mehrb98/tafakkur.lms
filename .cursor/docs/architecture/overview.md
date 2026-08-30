# System Architecture Overview

> **Full documentation (v2.0):** [v2/SAD.md](./v2/SAD.md) · **v2 suite index:** [v2/README.md](./v2/README.md)  
> **v1.0 (legacy):** [SAD.md](./SAD.md) · **Frontend planning:** [frontend-schema.md](./frontend-schema.md)

## Product

Learning Management System (LMS)

A multi-tenant SaaS platform designed for schools.

The platform allows multiple schools to manage:

- Students
- Teachers
- Parents
- Classes
- Subjects
- Attendance
- Grades
- Reports
- Communication
- Analytics


# Architecture Goals

The system must be:

- Secure
- Scalable
- Maintainable
- Testable
- Production-ready


# High Level Architecture


Users

↓

Next.js Frontend

↓

Rails API

↓

PostgreSQL

↓

Redis

↓

Sidekiq Workers

↓

External Services


External Services:

- Resend Email
- Object Storage
- Monitoring


# Main Components


## Frontend

Responsibilities:

- User interface
- Authentication flow
- Form handling
- Client interaction
- Dashboard visualization


Technology:

- Next.js
- React
- TypeScript
- HeroUI
- Tailwind CSS
- next-themes


## Backend

Responsibilities:

- Business logic
- Authentication
- Authorization
- API
- Database access


Technology:

- Ruby on Rails API
- PostgreSQL
- Redis


## Background Processing

Technology:

Sidekiq


Used for:

- Emails
- Reports
- Notifications
- Heavy tasks


# Architecture Principles


Follow:

- Separation of concerns
- Single responsibility
- Domain-driven thinking
- Secure by default
- Automated testing


# Communication


Frontend communicates with backend through:

REST API

Version:

/api/v1


Authentication:

JWT
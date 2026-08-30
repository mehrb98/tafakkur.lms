# Database Architecture

> **Full schema:** See [v2/database-schema.md](../architecture/v2/database-schema.md) for complete table definitions, indexes, and relationships. Legacy: [SAD.md §5](../architecture/SAD.md#5-database-design).

Database:

PostgreSQL


# Rules


Use UUID primary keys.


Every table contains:


created_at

updated_at


Tenant-owned tables contain:


school_id



# Main Tables


## schools


Purpose:

Tenant organization.


Fields:


id

name

domain

settings

created_at

updated_at



## users


Purpose:

Authentication users.


Fields:


id

school_id

email

password_digest

role

created_at

updated_at



## students


Fields:


id

school_id

user_id

first_name

last_name



## teachers


Fields:


id

school_id

user_id



## parents


Fields:


id

school_id

user_id



## classes


Fields:


id

school_id

name

academic_year_id



## subjects


Fields:


id

school_id

name



## grades


Fields:


id

school_id

student_id

subject_id

teacher_id

value

type



## attendance_records


Fields:


id

school_id

student_id

date

status



# Index Strategy


Always index:


Foreign keys

Search columns

Filtering columns


Example:


index students(school_id)

index grades(student_id)

index attendance(student_id,date)


# Data Integrity


Use:

Foreign keys

Unique constraints

Database constraints
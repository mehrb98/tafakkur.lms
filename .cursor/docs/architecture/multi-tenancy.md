# Multi Tenancy Architecture

## Decision

Use:

Shared Database + Tenant ID


Every tenant-owned record contains:

school_id


Example:


students

id

school_id

name



# Why This Approach


Advantages:

- Simple deployment
- Simple migrations
- Lower infrastructure cost
- Easy reporting
- Good scalability


# Alternatives Considered


## Database Per Tenant


Advantages:

- Strong isolation


Disadvantages:

- Complex migrations
- Expensive infrastructure


Rejected because:

Too complex initially.


## Schema Per Tenant


Advantages:

- Better isolation


Disadvantages:

- Migration complexity


Rejected because:

Operational overhead.


# Tenant Resolution


Tenant is determined from:

Authenticated user.


Never accept:

school_id

from frontend.


# Security Rules


Every query must include tenant scope.


Example:


Student.where(
school_id: current_user.school_id
)



# Future Scaling


If enterprise customers require:

Move selected tenants to dedicated databases.
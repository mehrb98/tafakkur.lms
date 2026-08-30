# API Guidelines

> **Full API reference (v2.0):** [architecture/v2/api-reference.md](../architecture/v2/api-reference.md)


## API Style


REST API


Version:


/api/v1


# Documentation


All endpoints must have:

Swagger/OpenAPI documentation.


Technology:

rswag


# Endpoint Requirements


Every endpoint contains:


Authentication

Authorization

Request schema

Response schema

Errors

Examples


# Response Format


Success:


{
 data: {}
}


Error:


{
 error:
 {
   code:"",
   message:"",
   details:[]
 }
}



# Pagination


All list endpoints support:


page

limit


# Filtering


Use query parameters.


Example:


GET /students?class_id=10


# Sorting


Example:


GET /students?sort=name


# Status Codes


200 OK

201 Created

204 No Content

400 Bad Request

401 Unauthorized

403 Forbidden

404 Not Found

422 Validation Error

500 Internal Error
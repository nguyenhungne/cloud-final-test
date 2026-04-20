# Testing /students-db Endpoint

## Overview
The `/students-db` endpoint connects to the MariaDB database and retrieves student records from the `studentdb.students` table.

## Prerequisites
- Docker and Docker Compose installed
- All services running via `docker-compose up`

## Testing Methods

### 1. Unit Tests
Run the unit tests locally:
```bash
cd hotenSVminicloud/application-backend-server
python -m pytest test_app.py::TestFlaskApp::test_students_db_endpoint -v
```

### 2. Test Database Connection (Inside Container)
```bash
# Enter the application container
docker exec -it application-backend-server sh

# Run the connection test script
python test_db_connection.py
```

### 3. HTTP Request Test
Once the services are running, test the endpoint:

```bash
# Using curl
curl http://localhost:8085/students-db

# Expected response:
[
  {
    "id": 1,
    "student_id": "SV001",
    "fullname": "Nguyen Van A",
    "dob": "2002-05-15",
    "major": "Computer Science"
  },
  {
    "id": 2,
    "student_id": "SV002",
    "fullname": "Tran Thi B",
    "dob": "2003-08-22",
    "major": "Information Technology"
  },
  {
    "id": 3,
    "student_id": "SV003",
    "fullname": "Le Van C",
    "dob": "2002-11-30",
    "major": "Software Engineering"
  }
]
```

### 4. Browser Test
Open in browser: http://localhost:8085/students-db

## Database Configuration
The endpoint uses these environment variables (with defaults):
- `DB_HOST`: relational-database-server
- `DB_PORT`: 3306
- `DB_USER`: root
- `DB_PASSWORD`: root
- `DB_NAME`: studentdb

## Implementation Details
- Uses `pymysql` library for database connectivity
- Returns JSON array of student records
- Converts date objects to ISO format strings
- Handles database errors gracefully with 500 status code

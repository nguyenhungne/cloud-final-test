#!/usr/bin/env python3
"""
Simple script to test database connection and query
This can be run inside the Docker container to verify connectivity
"""
import pymysql
import os
import sys

# Database configuration
DB_HOST = os.getenv('DB_HOST', 'relational-database-server')
DB_PORT = int(os.getenv('DB_PORT', '3306'))
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'root')
DB_NAME = os.getenv('DB_NAME', 'studentdb')

def test_connection():
    """Test database connection and query"""
    try:
        print(f"Attempting to connect to {DB_HOST}:{DB_PORT} as {DB_USER}...")
        
        # Connect to database
        connection = pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        
        print("✓ Connection successful!")
        
        try:
            with connection.cursor() as cursor:
                # Query all students
                cursor.execute("SELECT id, student_id, fullname, dob, major FROM students")
                students = cursor.fetchall()
                
                print(f"✓ Query successful! Found {len(students)} students:")
                for student in students:
                    print(f"  - {student['student_id']}: {student['fullname']} ({student['major']})")
                
                return True
        finally:
            connection.close()
            print("✓ Connection closed")
            
    except pymysql.Error as e:
        print(f"✗ Database error: {e}")
        return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

if __name__ == '__main__':
    success = test_connection()
    sys.exit(0 if success else 1)

import unittest
from unittest.mock import patch, MagicMock
from app import app, verify_token


class TestFlaskApp(unittest.TestCase):
    
    def setUp(self):
        """Set up test client"""
        self.app = app
        self.client = self.app.test_client()
        self.app.config['TESTING'] = True
    
    def test_hello_endpoint(self):
        """Test GET /hello returns correct JSON message"""
        response = self.client.get('/hello')
        
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json, {'message': 'Hello from App Server!'})
    
    def test_secure_endpoint_no_token(self):
        """Test GET /secure without token returns 401"""
        response = self.client.get('/secure')
        
        self.assertEqual(response.status_code, 401)
        self.assertIn('error', response.json)
    
    def test_secure_endpoint_invalid_header(self):
        """Test GET /secure with invalid auth header returns 401"""
        response = self.client.get('/secure', headers={
            'Authorization': 'InvalidFormat'
        })
        
        self.assertEqual(response.status_code, 401)
        self.assertIn('error', response.json)
    
    @patch('app.verify_token')
    def test_secure_endpoint_with_valid_token(self, mock_verify):
        """Test GET /secure with valid token returns user info"""
        # Mock successful token verification
        mock_verify.return_value = {
            'sub': '12345',
            'preferred_username': 'testuser',
            'email': 'test@example.com',
            'email_verified': True
        }
        
        response = self.client.get('/secure', headers={
            'Authorization': 'Bearer valid_token_here'
        })
        
        self.assertEqual(response.status_code, 200)
        self.assertIn('message', response.json)
        self.assertIn('user', response.json)
        self.assertEqual(response.json['user']['preferred_username'], 'testuser')
    
    @patch('app.verify_token')
    def test_secure_endpoint_with_invalid_token(self, mock_verify):
        """Test GET /secure with invalid token returns 401"""
        # Mock failed token verification
        mock_verify.return_value = None
        
        response = self.client.get('/secure', headers={
            'Authorization': 'Bearer invalid_token'
        })
        
        self.assertEqual(response.status_code, 401)
        self.assertIn('error', response.json)
    
    def test_student_endpoint(self):
        """Test GET /student returns list of students"""
        response = self.client.get('/student')
        
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json, list)
        self.assertEqual(len(response.json), 5)
        
        # Verify first student structure
        first_student = response.json[0]
        self.assertIn('id', first_student)
        self.assertIn('name', first_student)
        self.assertIn('major', first_student)
        self.assertIn('gpa', first_student)
    
    @patch('app.get_db_connection')
    def test_students_db_endpoint(self, mock_get_db):
        """Test GET /students-db returns list of students from database"""
        # Mock database connection and cursor
        mock_connection = MagicMock()
        mock_cursor = MagicMock()
        
        # Mock student data from database
        from datetime import date
        mock_cursor.fetchall.return_value = [
            {'id': 1, 'student_id': 'SV001', 'fullname': 'Nguyen Van A', 'dob': date(2002, 5, 15), 'major': 'Computer Science'},
            {'id': 2, 'student_id': 'SV002', 'fullname': 'Tran Thi B', 'dob': date(2003, 8, 22), 'major': 'Information Technology'},
            {'id': 3, 'student_id': 'SV003', 'fullname': 'Le Van C', 'dob': date(2002, 11, 30), 'major': 'Software Engineering'}
        ]
        
        mock_connection.cursor.return_value.__enter__.return_value = mock_cursor
        mock_get_db.return_value = mock_connection
        
        response = self.client.get('/students-db')
        
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json, list)
        self.assertEqual(len(response.json), 3)
        
        # Verify first student structure
        first_student = response.json[0]
        self.assertIn('id', first_student)
        self.assertIn('student_id', first_student)
        self.assertIn('fullname', first_student)
        self.assertIn('dob', first_student)
        self.assertIn('major', first_student)
        
        # Verify date is converted to string
        self.assertEqual(first_student['dob'], '2002-05-15')
        self.assertEqual(first_student['student_id'], 'SV001')
    
    @patch('app.get_db_connection')
    def test_students_db_endpoint_database_error(self, mock_get_db):
        """Test GET /students-db handles database errors"""
        import pymysql
        
        # Mock database error
        mock_get_db.side_effect = pymysql.Error("Connection failed")
        
        response = self.client.get('/students-db')
        
        self.assertEqual(response.status_code, 500)
        self.assertIn('error', response.json)
        self.assertIn('Database error', response.json['error'])


if __name__ == '__main__':
    unittest.main()

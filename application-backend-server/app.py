from flask import Flask, jsonify, request
from functools import wraps
import os
import json
import requests
import pymysql
from jose import jwt, JWTError
from jose.exceptions import ExpiredSignatureError, JWTClaimsError

app = Flask(__name__)

# Configuration from environment variables
OIDC_ISSUER = os.getenv('OIDC_ISSUER', 'http://authentication-identity-server:8080/realms/master')
OIDC_AUDIENCE = os.getenv('OIDC_AUDIENCE', 'account')

# Database configuration
DB_HOST = os.getenv('DB_HOST', 'relational-database-server')
DB_PORT = int(os.getenv('DB_PORT', '3306'))
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'root')
DB_NAME = os.getenv('DB_NAME', 'studentdb')

# Cache for JWKS
_jwks_cache = None


def get_jwks():
    """Fetch JWKS from Keycloak"""
    global _jwks_cache
    if _jwks_cache is None:
        try:
            jwks_url = f"{OIDC_ISSUER}/protocol/openid-connect/certs"
            response = requests.get(jwks_url, timeout=5)
            response.raise_for_status()
            _jwks_cache = response.json()
        except Exception as e:
            print(f"Error fetching JWKS: {e}")
            return None
    return _jwks_cache


def verify_token(token):
    """Verify OIDC token using python-jose"""
    try:
        # Get JWKS
        jwks = get_jwks()
        if not jwks:
            print("ERROR: Could not fetch JWKS")
            return None
        
        # Decode token header to get kid
        unverified_header = jwt.get_unverified_header(token)
        kid = unverified_header.get('kid')
        
        # Find the right key
        rsa_key = None
        for key in jwks.get('keys', []):
            if key.get('kid') == kid:
                rsa_key = key
                break
        
        if not rsa_key:
            print(f"ERROR: No matching key found for kid: {kid}")
            return None
        
        # Verify and decode token - skip issuer and audience validation for demo
        # First decode without verification to check token type
        unverified_payload = jwt.get_unverified_claims(token)
        token_type = unverified_payload.get('typ', 'Bearer')
        
        # Accept both Access tokens (typ: Bearer) and ID tokens (typ: ID)
        payload = jwt.decode(
            token,
            rsa_key,
            algorithms=['RS256'],
            options={"verify_aud": False, "verify_iss": False}
        )
        
        print(f"DEBUG: Token verified successfully for user: {payload.get('preferred_username', 'N/A')}")
        
        return payload
    
    except ExpiredSignatureError:
        print("ERROR: Token has expired")
        return None
    except JWTClaimsError as e:
        print(f"ERROR: JWT claims error: {e}")
        return None
    except JWTError as e:
        print(f"ERROR: JWT error: {e}")
        return None
    except Exception as e:
        print(f"ERROR: Unexpected error verifying token: {e}")
        import traceback
        traceback.print_exc()
        return None


def require_auth(f):
    """Decorator to require Bearer token authentication"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        
        if not auth_header:
            return jsonify({'error': 'No authorization header'}), 401
        
        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != 'bearer':
            return jsonify({'error': 'Invalid authorization header format'}), 401
        
        token = parts[1]
        payload = verify_token(token)
        
        if not payload:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        # Add user info to request context
        request.user_info = payload
        return f(*args, **kwargs)
    
    return decorated_function


@app.route('/hello', methods=['GET'])
def hello():
    """Public endpoint returning a simple JSON message"""
    return jsonify({'message': 'Hello from App Server!'})


@app.route('/secure', methods=['GET'])
@require_auth
def secure():
    """Protected endpoint requiring valid OIDC token"""
    user_info = request.user_info
    
    return jsonify({
        'message': 'Access granted to secure endpoint',
        'authenticated': True,
        'token_info': {
            'issuer': user_info.get('iss'),
            'subject': user_info.get('sub'),
            'client': user_info.get('azp'),
            'scope': user_info.get('scope'),
            'expires_at': user_info.get('exp'),
            'issued_at': user_info.get('iat')
        }
    })


@app.route('/student', methods=['GET'])
def student():
    """Public endpoint returning list of students from JSON file"""
    try:
        with open('students.json', 'r', encoding='utf-8') as f:
            students = json.load(f)
        return jsonify(students)
    except FileNotFoundError:
        return jsonify({'error': 'Students data not found'}), 404
    except json.JSONDecodeError:
        return jsonify({'error': 'Invalid JSON format'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def get_db_connection():
    """Create and return a database connection"""
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )


@app.route('/students-db', methods=['GET'])
def students_db():
    """Public endpoint returning list of students from MariaDB database"""
    try:
        # Connect to database
        connection = get_db_connection()
        
        try:
            with connection.cursor() as cursor:
                # Query all students from database
                cursor.execute("SELECT id, student_id, fullname, dob, major FROM students")
                students = cursor.fetchall()
                
                # Convert date objects to strings for JSON serialization
                for student in students:
                    if 'dob' in student and student['dob']:
                        student['dob'] = student['dob'].strftime('%Y-%m-%d')
                
                return jsonify(students)
        finally:
            connection.close()
            
    except pymysql.Error as e:
        return jsonify({'error': f'Database error: {str(e)}'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081, debug=True)

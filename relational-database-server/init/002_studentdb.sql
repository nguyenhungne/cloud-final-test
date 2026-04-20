-- Initialize studentdb database and students table
-- This script runs automatically when MariaDB container starts for the first time

-- Create database studentdb
CREATE DATABASE IF NOT EXISTS studentdb;

-- Use the studentdb database
USE studentdb;

-- Create students table with schema (id, student_id, fullname, dob, major)
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL UNIQUE,
    fullname VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    major VARCHAR(100) NOT NULL
);

-- Insert sample student data (at least 3 records)
INSERT INTO students (student_id, fullname, dob, major) VALUES 
    ('SV001', 'Nguyen Van A', '2002-05-15', 'Computer Science'),
    ('SV002', 'Tran Thi B', '2003-08-22', 'Information Technology'),
    ('SV003', 'Le Van C', '2002-11-30', 'Software Engineering');

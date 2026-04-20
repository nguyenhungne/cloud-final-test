-- Initialize minicloud database and notes table
-- This script runs automatically when MariaDB container starts for the first time

-- Create database minicloud
CREATE DATABASE IF NOT EXISTS minicloud;

-- Use the minicloud database
USE minicloud;

-- Create notes table with schema (id, title, created_at)
CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data into notes table
INSERT INTO notes (title) VALUES 
    ('Welcome to MyMiniCloud'),
    ('First note in the system'),
    ('Database initialization successful');

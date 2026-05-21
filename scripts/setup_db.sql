-- =============================================
-- WMS Database Setup Script
-- Run: mariadb -u root -p < scripts/setup_db.sql
-- =============================================

-- Create database
CREATE DATABASE IF NOT EXISTS wms
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Create user (modify password as needed)
CREATE USER IF NOT EXISTS 'wms_user'@'localhost' IDENTIFIED BY 'wms_password';
CREATE USER IF NOT EXISTS 'wms_user'@'127.0.0.1' IDENTIFIED BY 'wms_password';
CREATE USER IF NOT EXISTS 'wms_user'@'%' IDENTIFIED BY 'wms_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'localhost';
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'127.0.0.1';
GRANT ALL PRIVILEGES ON wms.* TO 'wms_user'@'%';

FLUSH PRIVILEGES;

-- Show result
SELECT 'Database wms created successfully' AS result;
SHOW DATABASES LIKE 'wms';

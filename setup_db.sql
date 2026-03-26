-- ============================================================
-- setup_db.sql
-- Create database, user, and table for sensor monitoring
-- Usage: sudo mysql < setup_db.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS sensor_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sensor_db;

-- Drop table if re-running
DROP TABLE IF EXISTS sensor_data;

CREATE TABLE sensor_data (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    timestamp   DATETIME     NOT NULL,
    temperature FLOAT        NOT NULL COMMENT 'Celsius',
    humidity    FLOAT        NOT NULL COMMENT 'Percent',
    pressure    FLOAT        NOT NULL COMMENT 'hPa',
    light_level FLOAT        NOT NULL COMMENT 'lux',
    INDEX idx_ts (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create dedicated monitoring user
CREATE USER IF NOT EXISTS 'monitor_user'@'localhost' IDENTIFIED BY 'monitor1234';
GRANT ALL PRIVILEGES ON sensor_db.* TO 'monitor_user'@'localhost';

-- Also allow Grafana to connect (read-only is enough)
CREATE USER IF NOT EXISTS 'grafana_user'@'localhost' IDENTIFIED BY 'grafana1234';
GRANT SELECT ON sensor_db.* TO 'grafana_user'@'localhost';

FLUSH PRIVILEGES;

SELECT 'setup_db.sql: Done. Database sensor_db is ready.' AS status;

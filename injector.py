#!/usr/bin/env python3
"""
injector.py
Random sensor data generator that inserts data into MySQL database.
Generates: temperature, humidity, pressure, light_level every 2 seconds.
"""

import random
import time
import datetime
import mysql.connector
from mysql.connector import Error

# --- DB Configuration ---
DB_CONFIG = {
    "host": "localhost",
    "user": "monitor_user",
    "password": "monitor1234",
    "database": "sensor_db",
}

# --- Data range settings ---
SENSOR_RANGES = {
    "temperature": (15.0, 40.0),   # Celsius
    "humidity":    (20.0, 90.0),   # %
    "pressure":    (980.0, 1025.0),# hPa
    "light_level": (0.0, 1000.0),  # lux
}

INTERVAL_SEC = 2   # insert interval (seconds)


def generate_record() -> dict:
    """Generate one random sensor record."""
    record = {"timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
    for key, (lo, hi) in SENSOR_RANGES.items():
        record[key] = round(random.uniform(lo, hi), 2)
    return record


def insert_record(cursor, record: dict) -> None:
    sql = """
        INSERT INTO sensor_data (timestamp, temperature, humidity, pressure, light_level)
        VALUES (%(timestamp)s, %(temperature)s, %(humidity)s, %(pressure)s, %(light_level)s)
    """
    cursor.execute(sql, record)


def main():
    print("=== Sensor Data Injector ===")
    print(f"Target DB : {DB_CONFIG['database']}@{DB_CONFIG['host']}")
    print(f"Interval  : {INTERVAL_SEC}s  (Ctrl+C to stop)\n")

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("[OK] Connected to MySQL\n")

        count = 0
        while True:
            record = generate_record()
            insert_record(cursor, record)
            conn.commit()
            count += 1
            print(
                f"[{count:>5}] {record['timestamp']} | "
                f"temp={record['temperature']:>5}°C  "
                f"hum={record['humidity']:>5}%  "
                f"press={record['pressure']:>7}hPa  "
                f"light={record['light_level']:>7}lux"
            )
            time.sleep(INTERVAL_SEC)

    except KeyboardInterrupt:
        print(f"\n[STOP] {count} records inserted. Goodbye.")
    except Error as e:
        print(f"[ERROR] MySQL: {e}")
    finally:
        try:
            cursor.close()
            conn.close()
        except Exception:
            pass


if __name__ == "__main__":
    main()

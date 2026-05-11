#!/usr/bin/env python3
"""
CSV Data Loader for Tembo Hotel Pipeline
Loads the dirty CSV data into the staging table in Neon PostgreSQL
"""

import pandas as pd
import psycopg2
import os
from urllib.parse import urlparse

def load_csv_to_staging(csv_path: str, connection_string: str):
    """
    Load CSV data into the bookings_staging table

    Args:
        csv_path: Path to the CSV file
        connection_string: PostgreSQL connection string
    """

    # Parse connection string
    parsed = urlparse(connection_string)
    conn_params = {
        'host': parsed.hostname,
        'port': parsed.port,
        'database': parsed.path.lstrip('/'),
        'user': parsed.username,
        'password': parsed.password,
        'sslmode': 'require',
        'channel_binding': 'require'
    }

    try:
        # Connect to database
        print("Connecting to Neon database...")
        conn = psycopg2.connect(**conn_params)
        cursor = conn.cursor()

        # Set search path
        cursor.execute("SET search_path TO tembo_hotel")

        # Read CSV
        print(f"Reading CSV file: {csv_path}")
        df = pd.read_csv(csv_path)

        print(f"Loaded {len(df)} rows with {len(df.columns)} columns")
        print(f"Columns: {list(df.columns)}")

        # Insert data
        print("Inserting data into staging table...")
        values = [tuple(row) for row in df.itertuples(index=False, name=None)]

        # Prepare INSERT statement
        columns = ', '.join(df.columns)
        placeholders = ', '.join(['%s'] * len(df.columns))
        insert_query = f"INSERT INTO bookings_staging ({columns}) VALUES ({placeholders})"

        cursor.executemany(insert_query, values)
        conn.commit()

        # Verify load
        cursor.execute("SELECT COUNT(*) FROM bookings_staging")
        count = cursor.fetchone()[0]
        print(f"Successfully loaded {count} rows into staging table")

    except Exception as e:
        print(f"Error loading data: {e}")
        if 'conn' in locals():
            conn.rollback()
        raise
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    # Configuration
    csv_path = "dataset/tembo_hotel_dirty.csv"
    connection_string = os.getenv('DATABASE_URL')

    if not connection_string:
        print("Error: DATABASE_URL environment variable not set")
        print("Please set it to your Neon connection string")
        exit(1)

    if not os.path.exists(csv_path):
        print(f"Error: CSV file not found at {csv_path}")
        exit(1)

    load_csv_to_staging(csv_path, connection_string)
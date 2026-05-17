#!/usr/bin/env python3
"""Load safari_connect_dirty.csv into bookings_staging on Neon PostgreSQL."""

import os
from urllib.parse import urlparse

import pandas as pd
import psycopg2

SCHEMA = "safari_connect"
TABLE = "bookings_staging"
DEFAULT_CSV = "dataset/safari_connect_dirty.csv"


def load_csv_to_staging(csv_path: str, connection_string: str) -> None:
    parsed = urlparse(connection_string)
    conn_params = {
        "host": parsed.hostname,
        "port": parsed.port,
        "database": parsed.path.lstrip("/"),
        "user": parsed.username,
        "password": parsed.password,
        "sslmode": "require",
    }

    conn = None
    try:
        print("Connecting to Neon database...")
        conn = psycopg2.connect(**conn_params)
        cursor = conn.cursor()
        cursor.execute(f"SET search_path TO {SCHEMA}")

        print(f"Reading CSV: {csv_path}")
        df = pd.read_csv(csv_path)
        print(f"Loaded {len(df)} rows, {len(df.columns)} columns")

        columns = ", ".join(df.columns)
        placeholders = ", ".join(["%s"] * len(df.columns))
        insert_query = f"INSERT INTO {TABLE} ({columns}) VALUES ({placeholders})"
        values = [tuple(row) for row in df.itertuples(index=False, name=None)]

        print("Inserting into bookings_staging...")
        cursor.executemany(insert_query, values)
        conn.commit()

        cursor.execute(f"SELECT COUNT(*) FROM {TABLE}")
        count = cursor.fetchone()[0]
        print(f"Staging row count: {count}")

    except Exception as exc:
        if conn:
            conn.rollback()
        raise RuntimeError(f"Failed to load CSV: {exc}") from exc
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    csv_path = os.getenv("CSV_PATH", DEFAULT_CSV)
    connection_string = os.getenv("DATABASE_URL")

    if not connection_string:
        print("Error: set DATABASE_URL to your Neon connection string")
        raise SystemExit(1)

    if not os.path.exists(csv_path):
        print(f"Error: CSV not found at {csv_path}")
        raise SystemExit(1)

    load_csv_to_staging(csv_path, connection_string)

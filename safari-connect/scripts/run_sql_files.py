#!/usr/bin/env python3
"""Execute SQL files in order against Neon (uses DATABASE_URL)."""

import os
import sys
from pathlib import Path
from urllib.parse import urlparse

import psycopg2

FILES = [
    "sql/cleaning/01_clean_staging.sql",
    "sql/ddl/02_production_table.sql",
    "sql/views/01_v_clean_trips.sql",
    "sql/views/02_analytic_views.sql",
    "sql/indexes/01_indexes.sql",
]


def run_file(cursor, path: Path) -> None:
    sql = path.read_text(encoding="utf-8")
    print(f"Running {path}...")
    cursor.execute(sql)


def main() -> None:
    connection_string = os.getenv("DATABASE_URL")
    if not connection_string:
        print("Error: DATABASE_URL not set")
        sys.exit(1)

    root = Path(__file__).resolve().parent.parent
    parsed = urlparse(connection_string)
    conn = psycopg2.connect(
        host=parsed.hostname,
        port=parsed.port,
        database=parsed.path.lstrip("/"),
        user=parsed.username,
        password=parsed.password,
        sslmode="require",
    )
    try:
        cursor = conn.cursor()
        for rel in FILES:
            run_file(cursor, root / rel)
        conn.commit()
        print("All SQL files executed successfully.")
    except Exception as exc:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()

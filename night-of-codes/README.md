# Crypto ETL Pipeline

This project is a simple crypto data pipeline built with Python. It fetches live cryptocurrency market data from the CoinGecko API, transforms the results into a clean format, and loads it into a PostgreSQL database hosted on Aiven.

## What this project does

1. Extracts data from the CoinGecko API for a list of selected cryptocurrencies.
2. Transforms the data into a structured format for storage.
3. Loads the cleaned data into a PostgreSQL table.
4. Runs SQL queries to explore the stored crypto data.

## Why this is useful

This project demonstrates a basic ETL workflow:

- Extract: get external data from an API.
- Transform: clean and prepare the data.
- Load: store the data in a database.

It is a good starter project for learning how to connect Python to PostgreSQL and work with real-world data.

## Project files

- `crypto_etl_colab.ipynb` - the main notebook. It contains all the steps, code, and queries.
- `README.md` - this file.

## Technologies used

- Python
- pandas
- requests
- psycopg2-binary
- PostgreSQL (Aiven cloud)
- CoinGecko API

## How the notebook is organized

- Install dependencies
- Import libraries
- Configure PostgreSQL connection
- Create the `crypto_prices` table
- Fetch crypto market data from CoinGecko
- Transform the raw API response into records
- Insert the records into PostgreSQL
- Run SQL queries to view the loaded data
- Run the pipeline end-to-end in one cell

## PostgreSQL setup

This notebook connects to a PostgreSQL database hosted on Aiven. To use it, you need:

- An Aiven PostgreSQL service
- Host, port, database name, username, password, and `sslmode`

Open the notebook and update the `DB_CONFIG` section with your own Aiven credentials.

The notebook includes a connection test and creates the `crypto_prices` table if it does not already exist.

## Running the notebook

1. Open `crypto_etl_colab.ipynb` in your notebook environment.
2. Update the `DB_CONFIG` values with your PostgreSQL connection details.
3. Run the cells in order.

If you run the full pipeline, it will fetch live crypto data and save it to the database.

## Important notes

- Do not commit your database credentials to any public repository.
- Use your own Aiven connection details before running the notebook.
- The table stores repeated snapshots, so running the pipeline multiple times adds more rows.

## Extending this project

You can improve it by:

- adding more cryptocurrencies to track
- saving data to a larger historical table
- scheduling the notebook or script to run regularly
- building visualizations or dashboards from the stored data
- adding error handling and retry logic for the API requests

## What you learn from this project

- how to use the CoinGecko API
- how to transform JSON data into a table-like format
- how to connect Python to PostgreSQL with `psycopg2`
- how to insert multiple rows efficiently using batch inserts
- how to query stored data using SQL from Python

# 🤖 Coding Agent Prompt — Student Data Pipeline Project

## Project Overview

You are helping build a **demo solution** for a student data handling assignment.
The goal is to produce a well-commented Jupyter Notebook (`.ipynb`) that walks
through a complete data pipeline — from fetching raw JSON data online to exporting
a clean CSV file.

This notebook will serve as a **reference/demo** that shows exactly what a student
is expected to submit.

---

## Dataset Details

- **Source:** Mockaroo (fake/generated data)
- **Format:** JSON — a list of dictionaries (~1000 rows)
- **GitHub file URL (viewer):**
  `https://github.com/Navashub/lux-cohort7/blob/main/mockaroo-csv/users_data.json`
- **Raw URL to use in the notebook (for `requests`):**
  `https://raw.githubusercontent.com/Navashub/lux-cohort7/main/mockaroo-csv/users_data.json`

> ⚠️ Always use the **raw URL** (raw.githubusercontent.com) when making HTTP requests
> — not the GitHub viewer URL.

---

## Pipeline Steps (One Cell Per Step)

Each step below must be:
- In its **own code cell**
- Preceded by a **markdown cell** explaining what the step does in simple,
  beginner-friendly language

### Step 1 — Install / Import Libraries
Import `requests` and `pandas`. No extra libraries allowed.

### Step 2 — Fetch the Data
Use `requests.get()` with the raw GitHub URL above.
Include basic error handling — check the HTTP status code before proceeding.
If the request fails, print a clear error message.

### Step 3 — Parse the JSON
Parse the response body into a Python list of dictionaries using `.json()`.
Print the total number of records fetched to confirm success.

### Step 4 — Trim to 100 Rows
Slice the list to keep only the **first 100 rows**.
Print the length to confirm the trim worked.

### Step 5 — Load into a pandas DataFrame
Use `pd.DataFrame()` to convert the trimmed list into a DataFrame.

### Step 6 — Inspect the DataFrame
Show the following in separate sub-steps:
- `.head()` — first 5 rows
- `.shape` — dimensions
- `.dtypes` — column data types

### Step 7 — Export to CSV
Use `.to_csv()` to save the DataFrame as a CSV file.
Set `index=False` so the row numbers are not written to the file.
Print a confirmation message with the output filename.

---

## Output Files Expected

| File | Description |
|------|-------------|
| `student_project.ipynb` | The Jupyter Notebook with all steps |
| `users_data_100.csv` | The exported CSV of the trimmed 100-row DataFrame |

---

## Technical Requirements

- Libraries: **`requests` and `pandas` only** — no other imports
- The notebook must run **top to bottom without errors** in:
  - Google Colab
  - Any standard Jupyter environment (Jupyter Lab / Notebook)
- Use the **raw GitHub URL** for the HTTP request
- `to_csv()` must have `index=False`
- Every code cell must have a markdown cell above it with a plain-English explanation

---

## What the Agent Should Do

1. Generate the `.ipynb` notebook file with all 7 steps as described
2. Make sure markdown explanations are student-friendly (assume beginner level)
3. Ensure the notebook is clean, readable, and runs without modification
4. Confirm both output files are produced: the notebook and the CSV

---

## No Further Input Needed

All required details are provided above. The agent should proceed directly to
building the notebook without asking for clarification.

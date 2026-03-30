[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/Ij5XubX8)
# Lab 3 — SQL Analytics

> Applied Lab for Module 3: SQL & Relational Data

## Overview

You will write SQL queries against a PostgreSQL database for **Levant Tech Solutions**, a fictional technology company. The database contains employees, departments, projects, and project assignments. You will practice JOINs, GROUP BY, window functions, CTEs, and schema design.

## Prerequisites

- PostgreSQL 15 running locally (installed during Pre-Work)
- Python 3.11 with `psycopg[binary]` (installed during EID 1)
- Your `.venv` activated

## Setup

1. **Clone your assignment repo** and `cd` into it.

2. **Create the database:**

   ```bash
   psql -h localhost -U postgres -c "CREATE DATABASE lab3;"
   ```

3. **Load the schema and seed data:**

   ```bash
   psql -h localhost -U postgres -d lab3 -f schema.sql
   psql -h localhost -U postgres -d lab3 -f seed_data.sql
   ```

4. **Verify the data loaded:**

   ```bash
   psql -h localhost -U postgres -d lab3 -c "SELECT COUNT(*) FROM employees;"
   ```

   You should see `60`.

## Your Task

1. **Write SQL queries** in `queries.sql` — one query per numbered block (Q1 through Q9).
2. **Complete the KPI brief** in `kpi_brief.md` — identify 3 KPIs from your query results.
3. **Test locally** before pushing:

   ```bash
   psql -h localhost -U postgres -d lab3 -f queries.sql
   ```

4. See the full lab guide on GitHub Pages (linked in TalentLMS) for detailed requirements and expected output descriptions.

## Running the Autograder Locally

```bash
pip install -r requirements.txt
pytest tests/ -v
```

> **Note:** The autograder checks that your files exist, that the schema and seed data load without errors, and that `queries.sql` executes without errors. It does not check query correctness — that is graded by the TA using the rubric.

## Submission

1. Create a branch (e.g., `lab-3-sql-analytics`)
2. Complete `queries.sql` and `kpi_brief.md`
3. Push and open a PR to `main`
4. Confirm the autograder passes (green check)
5. Paste your PR URL into TalentLMS → Module 3 → Lab 3

---

## License

This repository is provided for educational use only. See [LICENSE](LICENSE) for terms.

You may clone and modify this repository for personal learning and practice, and reference code you wrote here in your professional portfolio. Redistribution outside this course is not permitted.

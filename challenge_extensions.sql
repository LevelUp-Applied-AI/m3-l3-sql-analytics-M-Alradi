-- ============================================================
-- Tier 1 — Complex Analytics Queries
-- ============================================================

-- 1. Identify “At-Risk” Projects
SELECT 
    p.project_id,
    p.name AS project_name,
    p.budget,
    SUM(pa.hours_allocated) AS total_hours,
    ROUND((SUM(pa.hours_allocated) / p.budget) * 100, 2) AS utilization_percent
FROM projects p
JOIN project_assignments pa ON p.project_id = pa.project_id
GROUP BY p.project_id, p.name, p.budget
HAVING SUM(pa.hours_allocated) > 0.8 * p.budget
ORDER BY utilization_percent DESC;

-- 2. Cross-Department Analysis
WITH project_dept AS (
    SELECT 
        pa.project_id,
        e.department_id,
        COUNT(*) AS dept_count
    FROM project_assignments pa
    JOIN employees e ON pa.employee_id = e.employee_id
    GROUP BY pa.project_id, e.department_id
),
project_main_dept AS (
    SELECT project_id, department_id
    FROM (
        SELECT 
            project_id,
            department_id,
            dept_count,
            RANK() OVER (PARTITION BY project_id ORDER BY dept_count DESC) AS rnk
        FROM project_dept
    ) t
    WHERE rnk = 1
)
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.name AS employee_department,
    p.name AS project_name,
    d2.name AS project_department
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN project_assignments pa ON e.employee_id = pa.employee_id
JOIN projects p ON pa.project_id = p.project_id
JOIN project_main_dept pm ON p.project_id = pm.project_id
JOIN departments d2 ON pm.department_id = d2.department_id
WHERE e.department_id <> pm.department_id
ORDER BY employee_name;

-- ============================================================
-- Tier 2 — Dynamic Reporting with Views and Functions
-- ============================================================

-- 1. Department Summary View
DROP VIEW IF EXISTS department_summary CASCADE;
CREATE OR REPLACE VIEW department_summary AS
SELECT 
    d.department_id,
    d.name AS department_name,
    COUNT(e.employee_id) AS employee_count,
    SUM(e.salary) AS total_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.name;

-- 2. Project Status View
DROP VIEW IF EXISTS project_status CASCADE;
CREATE OR REPLACE VIEW project_status AS
SELECT 
    p.project_id,
    p.name AS project_name,
    p.start_date,
    p.end_date,
    p.budget,
    COALESCE(SUM(pa.hours_allocated),0) AS total_hours,
    CASE 
        WHEN p.end_date IS NULL THEN 'Active'
        WHEN CURRENT_DATE BETWEEN p.start_date AND p.end_date THEN 'Ongoing'
        WHEN CURRENT_DATE > p.end_date THEN 'Completed'
        ELSE 'Planned'
    END AS status
FROM projects p
LEFT JOIN project_assignments pa ON p.project_id = pa.project_id
GROUP BY p.project_id, p.name, p.start_date, p.end_date, p.budget;

-- 3. Materialized View Example
DROP MATERIALIZED VIEW IF EXISTS project_status_mat CASCADE;
CREATE MATERIALIZED VIEW project_status_mat AS
SELECT * FROM project_status;

-- Refresh when needed
REFRESH MATERIALIZED VIEW project_status_mat;

-- 4. PL/pgSQL Function Returning JSON
CREATE OR REPLACE FUNCTION department_report(dept_name TEXT)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'department', d.name,
        'employee_count', COUNT(e.employee_id),
        'total_salary', SUM(e.salary),
        'active_projects', COUNT(DISTINCT p.project_id)
    )
    INTO result
    FROM departments d
    LEFT JOIN employees e ON d.department_id = e.department_id
    LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
    LEFT JOIN projects p ON pa.project_id = p.project_id AND (p.end_date IS NULL OR p.end_date > CURRENT_DATE)
    WHERE d.name = dept_name
    GROUP BY d.name;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Tier 3 — Schema Evolution and Migration
-- ============================================================

-- 1. Salary History Table
DROP TABLE IF EXISTS salary_history CASCADE;
CREATE TABLE salary_history (
    history_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    salary NUMERIC(12,2),
    effective_date DATE NOT NULL,
    change_reason TEXT
);

-- 2. Migration Script (Initial Backfill)
INSERT INTO salary_history (employee_id, salary, effective_date, change_reason)
SELECT employee_id, salary, CURRENT_DATE, 'Initial import'
FROM employees
ON CONFLICT DO NOTHING;

-- 3. Example Seed Data
INSERT INTO salary_history (employee_id, salary, effective_date, change_reason) VALUES
(1, 90000, '2023-01-01', 'Annual raise'),
(1, 95000, '2024-01-01', 'Annual raise'),
(1, 97000, '2025-01-01', 'Performance bonus')
ON CONFLICT DO NOTHING;

-- 4. Queries on Salary History

-- Salary Growth Rate by Department
SELECT 
    d.name AS department_name,
    ROUND( (MAX(sh.salary) - MIN(sh.salary)) / MIN(sh.salary) * 100, 2 ) AS growth_rate_percent
FROM salary_history sh
JOIN employees e ON sh.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.name;

-- Employees Due for Salary Review (no change in 12+ months)
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    MAX(sh.effective_date) AS last_change
FROM employees e
JOIN salary_history sh ON e.employee_id = sh.employee_id
GROUP BY e.employee_id, employee_name
HAVING MAX(sh.effective_date) < CURRENT_DATE - INTERVAL '12 months';

-- 5. Brief Analysis (Production Migration)
-- Approach:
--   - Create salary_history table
--   - Backfill current salaries
--   - Add triggers so updates to employees.salary insert into salary_history
-- Risks:
--   - Data consistency: may miss historical changes
--   - Performance: triggers add overhead
--   - Migration downtime: avoid salary updates during migration
-- Mitigation:
--   - Run migration during low-traffic window
--   - Validate with checksums
--   - Communicate with HR/Finance teams before rollout
# KPI Brief — Levant Tech Solutions

## KPI 1: [KPI: Department Salary Efficiency]

**Definition:**
Average salary per employee by department.
Calculated using the employees table:

SELECT d.name,
       COUNT(e.employee_id) AS employee_count,
       SUM(e.salary) AS total_salary,
       ROUND(AVG(e.salary), 2) AS avg_salary
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.name;

**Current value:**
- Total Salary: 880,000
- Employees: 12
- Average Salary: 73,333.33

**Interpretation:**
Engineering has the highest payroll concentration, indicating it is the company’s most resource-intensive and strategically critical department.


## KPI 2: [Employee Utilization Rate]

**Definition:**

Percentage of employees assigned to at least one project.
Calculated using employees and project_assignments:

SELECT 
  ROUND(
    (COUNT(DISTINCT pa.employee_id) * 100.0) 
    / (SELECT COUNT(*) FROM employees), 
  2) AS utilization_rate
FROM project_assignments pa;

**Current value:**
Assigned Employees: 50
Total Employees: 60
Utilization Rate: 83.33%

**Interpretation:**
83% of employees are contributing to projects, meaning 17% (Customer Support team) are currently not utilized in project work.

## KPI 3: [Project Staffing Ratio]

**Definition:**
Average number of employees assigned per project.
Calculated using projects and project_assignments:

SELECT 
  ROUND(
    COUNT(pa.assignment_id) * 1.0 
    / COUNT(DISTINCT p.project_id), 
  2) AS avg_assignments_per_project
FROM projects p
LEFT JOIN project_assignments pa 
  ON p.project_id = pa.project_id;

**Current value:**
Total Assignments: 80
Total Projects: 15
Average: 5.33 employees per project

**Interpretation:**
Projects are staffed with about 5–6 employees on average, suggesting moderately sized cross-functional teams.
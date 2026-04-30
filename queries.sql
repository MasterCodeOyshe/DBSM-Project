-- ============================================================
-- BiDi Database System - Queries
-- Member 3: Parsa Najafi
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: All Employees with Department
-- ------------------------------------------------------------
SELECT e.EmpID,
       e.Name AS EmployeeName,
       e.Email,
       d.Name AS Department
FROM Employee e
JOIN Department d ON e.DepID = d.DepID
ORDER BY d.Name, e.Name;


-- ------------------------------------------------------------
-- Query 2: High-Budget Projects
-- ------------------------------------------------------------
SELECT PrID,
       Name,
       Budget,
       StartDate,
       Deadline
FROM Project
WHERE Budget > 50000
ORDER BY Budget DESC;


-- ------------------------------------------------------------
-- Query 3: Employee, Department, and Office Location
-- ------------------------------------------------------------
SELECT e.Name AS Employee,
       d.Name AS Department,
       l.Address,
       l.Country
FROM Employee e
JOIN Department d ON e.DepID = d.DepID
JOIN Location l ON d.LID = l.LID
ORDER BY l.Country, d.Name;


-- ------------------------------------------------------------
-- Query 4: Project, Customer, and Assigned Employees
-- ------------------------------------------------------------
SELECT p.Name AS Project,
       c.Name AS Customer,
       e.Name AS Employee,
       w.Started
FROM Project p
JOIN Customer c ON p.CID = c.CID
JOIN Works w ON p.PrID = w.PrID
JOIN Employee e ON w.EmpID = e.EmpID
ORDER BY p.Name;


-- ------------------------------------------------------------
-- Query 5: Employees and Their Assigned Roles
-- ------------------------------------------------------------
SELECT e.Name AS Employee,
       r.Name AS Role,
       er.Description
FROM Employee e
JOIN EmployeeRole er ON e.EmpID = er.EmpID
JOIN Role r ON er.RoleID = r.RoleID
ORDER BY e.Name;


-- ------------------------------------------------------------
-- Query 6: Employee Count per Department
-- ------------------------------------------------------------
SELECT d.Name AS Department,
       COUNT(e.EmpID) AS EmployeeCount
FROM Department d
LEFT JOIN Employee e ON d.DepID = e.DepID
GROUP BY d.Name
HAVING COUNT(e.EmpID) > 0
ORDER BY EmployeeCount DESC;


-- ------------------------------------------------------------
-- Query 7: Total Project Budget per Customer
-- ------------------------------------------------------------
SELECT c.Name AS Customer,
       COUNT(p.PrID) AS ProjectCount,
       SUM(p.Budget) AS TotalBudget
FROM Customer c
JOIN Project p ON c.CID = p.CID
GROUP BY c.Name
HAVING SUM(p.Budget) > 10000
ORDER BY TotalBudget DESC;
-- ============================================================
-- BiDi Database – Sample Data
-- Run AFTER schema.sql
-- Designed to:
--   - Make all JOIN queries return meaningful results
--   - Allow all triggers to be demonstrated
--   - Support GROUP BY / aggregation queries
--   - Enable role-based access control demo
-- ============================================================

-- ============================================================
-- 1. Locations  (3 Finnish offices as per project description)
-- ============================================================
INSERT INTO Location (Address, Country) VALUES
    ('Lappeenranta, Skinnarilankatu 34', 'Finland'),   -- LID 1: LUT Campus / Lahti
    ('Helsinki, Mannerheimintie 12',     'Finland'),   -- LID 2: Helsinki office
    ('Tampere, Hatanpään valtatie 24',   'Finland');   -- LID 3: Tampere office

-- ============================================================
-- 2. Departments  (5 departments from project description)
-- ============================================================
INSERT INTO Department (Name, LID) VALUES
    ('HR',               1),   -- DepID 1
    ('Software',         1),   -- DepID 2
    ('Data',             2),   -- DepID 3
    ('ICT',              2),   -- DepID 4
    ('Customer Support', 3);   -- DepID 5

-- ============================================================
-- 3. Customers  (6 customers across different locations)
-- ============================================================
INSERT INTO Customer (Name, Email, LID) VALUES
    ('MediCare Systems Oy',      'contact@medicare.fi',      1),  -- CID 1
    ('HealthBridge Finland',     'info@healthbridge.fi',     2),  -- CID 2
    ('Nordic Health Solutions',  'hello@nordichealth.fi',    2),  -- CID 3
    ('Tampere University Hospital', 'projects@tays.fi',      3),  -- CID 4
    ('DigiHealth Group',         'admin@digihealth.fi',      1),  -- CID 5
    ('Finnish Medical Institute','fmi@fmi.fi',               3);  -- CID 6

-- ============================================================
-- 4. Employees  (12 employees across all departments)
-- ============================================================
INSERT INTO Employee (Email, Name, DepID) VALUES
    ('anna.makinen@bidi.fi',     'Anna Mäkinen',     1),   -- EmpID 1  HR
    ('jukka.virtanen@bidi.fi',   'Jukka Virtanen',   1),   -- EmpID 2  HR
    ('sofia.laine@bidi.fi',      'Sofia Laine',      2),   -- EmpID 3  Software
    ('mikko.korhonen@bidi.fi',   'Mikko Korhonen',   2),   -- EmpID 4  Software
    ('aleksi.nieminen@bidi.fi',  'Aleksi Nieminen',  2),   -- EmpID 5  Software
    ('laura.heikkinen@bidi.fi',  'Laura Heikkinen',  3),   -- EmpID 6  Data
    ('pekka.hamalainen@bidi.fi', 'Pekka Hämäläinen', 3),   -- EmpID 7  Data
    ('hanna.järvinen@bidi.fi',   'Hanna Järvinen',   4),   -- EmpID 8  ICT
    ('timo.lehtinen@bidi.fi',    'Timo Lehtinen',    4),   -- EmpID 9  ICT
    ('paula.koskinen@bidi.fi',   'Paula Koskinen',   5),   -- EmpID 10 Customer Support
    ('risto.mäkela@bidi.fi',     'Risto Mäkelä',     5),   -- EmpID 11 Customer Support
    ('erika.salo@bidi.fi',       'Erika Salo',       3);   -- EmpID 12 Data

-- ============================================================
-- 5. Roles
-- ============================================================
INSERT INTO Role (Name) VALUES
    ('Project Manager'),    -- RoleID 1
    ('Lead Developer'),     -- RoleID 2
    ('Data Analyst'),       -- RoleID 3
    ('QA Engineer'),        -- RoleID 4
    ('System Architect'),   -- RoleID 5
    ('Support Specialist'); -- RoleID 6

-- ============================================================
-- 6. UserGroups
-- ============================================================
INSERT INTO UserGroup (Name) VALUES
    ('Tech Team'),          -- GrID 1
    ('Management'),         -- GrID 2
    ('Data Team'),          -- GrID 3
    ('Support Team');       -- GrID 4

-- ============================================================
-- 7. Projects  (8 projects: mix of active, future, no-deadline)
--    CIDs must reference existing customers (1–6)
--    Budgets all > 0 (chk_project_budget)
--    Deadlines all >= StartDate (chk_project_dates)
-- ============================================================
INSERT INTO Project (Name, Budget, CID, StartDate, Deadline) VALUES
    ('Patient Records Portal',       125000.00, 1, '2024-01-15', '2024-12-31'),  -- PrID 1
    ('Hospital Analytics Dashboard', 210000.00, 2, '2024-03-01', '2025-06-30'),  -- PrID 2
    ('ICT Infrastructure Upgrade',    87500.00, 3, '2024-06-01', '2024-11-30'),  -- PrID 3 (past deadline - for trigger demo)
    ('Remote Patient Monitoring',    175000.00, 4, '2024-09-01', '2025-09-01'),  -- PrID 4
    ('Data Migration Project',        55000.00, 5, '2025-01-10', '2025-07-10'),  -- PrID 5
    ('Security Audit & Compliance',   42000.00, 6, '2025-02-01', '2025-08-01'),  -- PrID 6
    ('AI Diagnostics Platform',      320000.00, 2, '2025-03-15', NULL),          -- PrID 7 (no deadline - ongoing)
    ('Support Desk Modernisation',    68000.00, 4, '2024-11-01', '2025-11-01');  -- PrID 8

-- ============================================================
-- 8. Works  (employees assigned to projects)
--    Only assign to non-expired projects for normal inserts.
--    PrID 3 deadline was 2024-11-30 (past) – used for trigger demo separately.
-- ============================================================
INSERT INTO Works (PrID, EmpID, Started) VALUES
    -- Project 1: Patient Records Portal
    (1, 3, '2024-01-15'),  -- Sofia (Software)
    (1, 4, '2024-01-15'),  -- Mikko (Software)
    (1, 6, '2024-02-01'),  -- Laura (Data)
    (1, 8, '2024-02-01'),  -- Hanna (ICT)
    -- Project 2: Hospital Analytics Dashboard
    (2, 4, '2024-03-01'),  -- Mikko (Software)
    (2, 6, '2024-03-01'),  -- Laura (Data)
    (2, 7, '2024-03-15'),  -- Pekka (Data)
    (2, 9, '2024-04-01'),  -- Timo (ICT)
    -- Project 4: Remote Patient Monitoring
    (4, 3, '2024-09-01'),  -- Sofia (Software)
    (4, 5, '2024-09-01'),  -- Aleksi (Software)
    (4, 12,'2024-09-15'),  -- Erika (Data)
    -- Project 5: Data Migration Project
    (5, 6, '2025-01-10'),  -- Laura (Data)
    (5, 7, '2025-01-10'),  -- Pekka (Data)
    (5, 12,'2025-01-20'),  -- Erika (Data)
    -- Project 6: Security Audit
    (6, 8, '2025-02-01'),  -- Hanna (ICT)
    (6, 9, '2025-02-01'),  -- Timo (ICT)
    -- Project 7: AI Diagnostics Platform (ongoing)
    (7, 3, '2025-03-15'),  -- Sofia (Software)
    (7, 5, '2025-03-15'),  -- Aleksi (Software)
    (7, 6, '2025-04-01'),  -- Laura (Data)
    (7, 7, '2025-04-01'),  -- Pekka (Data)
    -- Project 8: Support Desk Modernisation
    (8, 10,'2024-11-01'),  -- Paula (Support)
    (8, 11,'2024-11-01');  -- Risto (Support)

-- ============================================================
-- 9. EmployeeRole  (employee role assignments with descriptions)
-- ============================================================
INSERT INTO EmployeeRole (EmpID, RoleID, Description) VALUES
    (1,  1, 'HR manager overseeing project staffing'),
    (3,  2, 'Lead developer on patient records systems'),
    (4,  2, 'Lead developer on analytics platform'),
    (4,  4, 'Also responsible for QA on Hospital Analytics'),
    (5,  2, 'Lead developer on AI diagnostics'),
    (6,  3, 'Senior data analyst across multiple projects'),
    (7,  3, 'Data analyst specialising in healthcare data'),
    (8,  5, 'System architect for ICT infrastructure'),
    (9,  4, 'QA engineer for ICT and security projects'),
    (10, 6, 'Customer support specialist'),
    (11, 6, 'Customer support specialist'),
    (12, 3, 'Junior data analyst on migration and AI projects');
    -- EmpID 2 intentionally has no role (Description DEFAULT will apply if added)

-- ============================================================
-- 10. UserGroupMember  (group memberships)
-- ============================================================
INSERT INTO UserGroupMember (GrID, EmpID) VALUES
    -- Tech Team (GrID 1)
    (1, 3),
    (1, 4),
    (1, 5),
    (1, 8),
    (1, 9),
    -- Management (GrID 2)
    (2, 1),
    (2, 2),
    -- Data Team (GrID 3)
    (3, 6),
    (3, 7),
    (3, 12),
    -- Support Team (GrID 4)
    (4, 10),
    (4, 11);

-- ============================================================
-- TRIGGER DEMO STATEMENTS
-- (Run these AFTER the above data is inserted)
-- ============================================================

-- TRIGGER 1 DEMO: Try to assign an employee to Project 3 (deadline: 2024-11-30, PAST)
-- Expected: ERROR – Cannot assign employee 4 to project 3: deadline has passed.
-- INSERT INTO Works (PrID, EmpID, Started) VALUES (3, 4, '2025-01-01');

-- TRIGGER 2 DEMO: Try to remove the last member of Support Team (GrID 4)
-- First remove one member (this should succeed, 2 members left):
-- DELETE FROM UserGroupMember WHERE GrID = 4 AND EmpID = 11;
-- Then try to remove the last one (should fail):
-- DELETE FROM UserGroupMember WHERE GrID = 4 AND EmpID = 10;

-- TRIGGER 3 DEMO: Move an employee to a different department (should log to audit table)
-- UPDATE Employee SET DepID = 2 WHERE EmpID = 12;
-- Check the log: SELECT * FROM DepartmentAuditLog;

-- ============================================================
-- CONSTRAINT VIOLATION DEMOS
-- ============================================================

-- chk_project_budget: Budget must be > 0
-- INSERT INTO Project (Name, Budget, CID, StartDate) VALUES ('Bad Project', -500, 1, '2025-01-01');

-- chk_project_dates: Deadline must be >= StartDate
-- INSERT INTO Project (Name, Budget, CID, StartDate, Deadline) VALUES ('Bad Dates', 10000, 1, '2025-06-01', '2025-01-01');

-- chk_customer_email: Email must contain @
-- INSERT INTO Customer (Name, Email, LID) VALUES ('Bad Customer', 'notanemail', 1);

-- FK RESTRICT demo: Cannot delete a Location that has Departments
-- DELETE FROM Location WHERE LID = 1;

-- ============================================================
-- ACCESS CONTROL SETUP
-- (Run as superuser/admin – skip if your platform doesn't support it)
-- ============================================================

-- Create roles
CREATE ROLE db_employee;
CREATE ROLE db_manager;
CREATE ROLE db_admin;
CREATE ROLE db_readonly;

-- Grant privileges
GRANT SELECT ON Customer, Location TO db_employee;
GRANT SELECT, INSERT, UPDATE ON Department, Employee, Customer,
      EmployeeRole, Location, Project, Works TO db_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db_readonly;

-- Create users
CREATE USER antti  WITH PASSWORD 'antti123';
CREATE USER dora   WITH PASSWORD 'dora123';
CREATE USER parsa  WITH PASSWORD 'parsa123';

-- Assign roles
GRANT db_employee TO antti;
GRANT db_manager  TO dora;
GRANT db_admin    TO parsa;

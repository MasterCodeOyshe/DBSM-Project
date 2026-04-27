-- ============================================================
-- BiDi Database – Relational Schema (PostgreSQL)
-- Converted from the Conceptual ER Diagram (Section 4.1)
-- ============================================================

-- Drop tables in reverse-dependency order (for re-runnability)
DROP TABLE IF EXISTS UserGroupMember  CASCADE;
DROP TABLE IF EXISTS EmployeeRole     CASCADE;
DROP TABLE IF EXISTS Works            CASCADE;
DROP TABLE IF EXISTS Project          CASCADE;
DROP TABLE IF EXISTS Employee         CASCADE;
DROP TABLE IF EXISTS Department       CASCADE;
DROP TABLE IF EXISTS Customer         CASCADE;
DROP TABLE IF EXISTS Location         CASCADE;
DROP TABLE IF EXISTS Role             CASCADE;
DROP TABLE IF EXISTS UserGroup        CASCADE;

-- ============================================================
-- 1. Location
--    Independent entity – no foreign keys.
-- ============================================================
CREATE TABLE Location (
    LID      SERIAL       PRIMARY KEY,
    Address  VARCHAR(255) NOT NULL,
    Country  VARCHAR(100) NOT NULL DEFAULT 'Finland'
    -- DEFAULT: BiDi operates in Finland, so 'Finland' is a sensible default.
);

-- ============================================================
-- 2. Department
--    Each department is IN exactly one location (1..1 on Location side).
--    ON DELETE RESTRICT  – cannot remove a location while departments exist there.
--    ON UPDATE CASCADE   – if a location ID changes, propagate to departments.
-- ============================================================
CREATE TABLE Department (
    DepID  SERIAL       PRIMARY KEY,
    Name   VARCHAR(100) NOT NULL UNIQUE,
    LID    INT          NOT NULL,

    CONSTRAINT fk_department_location
        FOREIGN KEY (LID) REFERENCES Location(LID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================================
-- 3. Customer
--    Each customer is IN exactly one location (1..1 on Location side).
--    ON DELETE RESTRICT  – cannot remove a location that still has customers.
--    ON UPDATE CASCADE   – propagate location ID changes.
-- ============================================================
CREATE TABLE Customer (
    CID    SERIAL       PRIMARY KEY,
    Name   VARCHAR(150) NOT NULL,
    Email  VARCHAR(255) NOT NULL UNIQUE,
    LID    INT          NOT NULL,

    CONSTRAINT fk_customer_location
        FOREIGN KEY (LID) REFERENCES Location(LID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- CHECK: email must contain '@' (basic format validation)
    CONSTRAINT chk_customer_email CHECK (Email LIKE '%@%')
);

-- ============================================================
-- 4. Employee
--    Each employee is IN exactly one department (1..1 on Department side).
--    ON DELETE RESTRICT  – cannot delete a department that still has employees.
--    ON UPDATE CASCADE   – propagate department ID changes.
-- ============================================================
CREATE TABLE Employee (
    EmpID  SERIAL       PRIMARY KEY,
    Email  VARCHAR(255) NOT NULL UNIQUE,
    Name   VARCHAR(150) NOT NULL,
    DepID  INT          NOT NULL,

    CONSTRAINT fk_employee_department
        FOREIGN KEY (DepID) REFERENCES Department(DepID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- CHECK: employee email must contain '@'
    CONSTRAINT chk_employee_email CHECK (Email LIKE '%@%')
);

-- ============================================================
-- 5. Project
--    Commissions relationship (Project – Customer):
--      Customer (1..1) commissions Project (1..N)
--      → each project belongs to exactly one customer → FK CID in Project.
--    ON DELETE RESTRICT  – cannot delete a customer who has active projects.
--    ON UPDATE CASCADE   – propagate customer ID changes.
--    Relationship attributes startDate and deadline live here because
--    the relationship is 1:N (each project has exactly one commissioning).
-- ============================================================
CREATE TABLE Project (
    PrID      SERIAL         PRIMARY KEY,
    Name      VARCHAR(200)   NOT NULL,
    Budget    NUMERIC(15, 2) NOT NULL,
    CID       INT            NOT NULL,
    StartDate DATE           NOT NULL DEFAULT CURRENT_DATE,
    Deadline  DATE,

    CONSTRAINT fk_project_customer
        FOREIGN KEY (CID) REFERENCES Customer(CID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- CHECK: budget must be positive
    CONSTRAINT chk_project_budget CHECK (Budget > 0),

    -- CHECK: deadline must be after start date (when both are set)
    CONSTRAINT chk_project_dates CHECK (Deadline IS NULL OR Deadline >= StartDate)
    -- DEFAULT: StartDate defaults to today (CURRENT_DATE)
);

-- ============================================================
-- 6. Role
--    Independent entity – no foreign keys.
-- ============================================================
CREATE TABLE Role (
    RoleID  SERIAL       PRIMARY KEY,
    Name    VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- 7. UserGroup
--    Independent entity – no foreign keys.
-- ============================================================
CREATE TABLE UserGroup (
    GrID  SERIAL       PRIMARY KEY,
    Name  VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- ASSOCIATIVE TABLES (M:N Relationships)
-- ============================================================

-- ============================================================
-- 8. Works  (Project ↔ Employee, M:N)
--    Attribute: started (date the employee started on the project).
--    Composite PK (PrID, EmpID).
--    ON DELETE CASCADE – if a project or employee is removed, 
--                        their work assignments are removed too.
--    ON UPDATE CASCADE – propagate ID changes.
-- ============================================================
CREATE TABLE Works (
    PrID    INT  NOT NULL,
    EmpID   INT  NOT NULL,
    Started DATE NOT NULL DEFAULT CURRENT_DATE,
    -- DEFAULT: assignment start defaults to today.

    PRIMARY KEY (PrID, EmpID),

    CONSTRAINT fk_works_project
        FOREIGN KEY (PrID) REFERENCES Project(PrID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_works_employee
        FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================
-- 9. EmployeeRole  (Employee ↔ Role, M:N – "Has" relationship)
--    Attribute: Description (describes the role assignment context).
--    Composite PK (EmpID, RoleID).
--    ON DELETE CASCADE – removing an employee or role removes the assignment.
--    ON UPDATE CASCADE – propagate ID changes.
-- ============================================================
CREATE TABLE EmployeeRole (
    EmpID       INT          NOT NULL,
    RoleID      INT          NOT NULL,
    Description VARCHAR(500) DEFAULT 'No description provided',
    -- DEFAULT: fallback description when none is given.

    PRIMARY KEY (EmpID, RoleID),

    CONSTRAINT fk_emprole_employee
        FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_emprole_role
        FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================
-- 10. UserGroupMember  (UserGroup ↔ Employee, M:N – "PartOf" relationship)
--     Employee side is (0..N) – an employee may belong to zero or more groups.
--     UserGroup side is (1..N) – a group must have at least one member
--       (enforced at application/trigger level, not by schema alone).
--     Composite PK (GrID, EmpID).
--     ON DELETE CASCADE – removing a group or employee removes the membership.
--     ON UPDATE CASCADE – propagate ID changes.
-- ============================================================
CREATE TABLE UserGroupMember (
    GrID   INT NOT NULL,
    EmpID  INT NOT NULL,

    PRIMARY KEY (GrID, EmpID),

    CONSTRAINT fk_ugm_usergroup
        FOREIGN KEY (GrID) REFERENCES UserGroup(GrID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_ugm_employee
        FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================
-- SUMMARY OF ON DELETE / ON UPDATE JUSTIFICATIONS
-- ============================================================
--
-- FK in Department → Location:
--   ON DELETE RESTRICT – A location cannot be deleted if departments still
--                        reference it; reassign departments first.
--   ON UPDATE CASCADE  – If a location PK changes, keep departments consistent.
--
-- FK in Customer → Location:
--   ON DELETE RESTRICT – Same reasoning as above for customer locations.
--   ON UPDATE CASCADE  – Propagate any PK update.
--
-- FK in Employee → Department:
--   ON DELETE RESTRICT – A department cannot be removed while employees
--                        are assigned; transfer employees first.
--   ON UPDATE CASCADE  – Propagate department ID changes.
--
-- FK in Project → Customer:
--   ON DELETE RESTRICT – A customer with commissioned projects cannot be
--                        deleted; projects must be resolved first.
--   ON UPDATE CASCADE  – Propagate customer ID changes.
--
-- FKs in Works, EmployeeRole, UserGroupMember (associative tables):
--   ON DELETE CASCADE  – Removing a parent entity (project, employee, role,
--                        user group) should automatically clean up the
--                        many-to-many link rows, since the association no
--                        longer makes sense without both participants.
--   ON UPDATE CASCADE  – Keep link rows consistent with any PK changes.
-- ============================================================


-- ============================================================
-- ROLE CREATION
-- ============================================================

CREATE ROLE db_employee;
CREATE ROLE db_manager;
CREATE ROLE db_admin;

CREATE ROLE Antti LOGIN PASSWORD '1234';
GRANT db_employee TO Antti;

CREATE ROLE Dora LOGIN PASSWORD '5678';
Grant db_manager TO Dora;

CREATE ROLE Parsa LOGIN PASSWORD '3456';
Grant db_admin TO Parsa;

GRANT CONNECT ON DATABASE g3 TO db_employee, db_manager, db_admin;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO db_admin;

GRANT SELECT ON TABLE customer, location TO db_employee;

GRANT SELECT, INSERT, UPDATE ON TABLE 
    department,
    employee,
    customer,
    employeerole,
    location,
    project,
    works
TO db_manager;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO db_manager;

-- ============================================================
-- SAMPLE DATASET (AI generated)
-- ============================================================

-- Locations
INSERT INTO Location (Address, Country) VALUES
('Helsinki Central Hospital', 'Finland'),
('Espoo Medical Center', 'Finland'),
('Tampere University Hospital', 'Finland'),
('Oulu Health Clinic', 'Finland');

-- Departments
INSERT INTO Department (Name, LID) VALUES
('IT Systems', 1),
('Administration', 2),
('Billing', 3),
('Research', 4);

-- Customers
INSERT INTO Customer (Name, Email, LID) VALUES
('John Doe', 'john.doe@email.com', 1),
('Anna Virtanen', 'anna.virtanen@email.com', 2),
('City Health Services', 'contact@chs.fi', 1),
('Private Clinic Group', 'info@pcg.fi', 1),
('Rehab Center Oy', 'info@rehab.fi', 2),
('Mental Health Org', 'support@mho.fi', 2),
('Children Hospital Assoc', 'info@cha.fi', 3),
('Elderly Care Group', 'contact@ecg.fi', 3),
('Pharma Logistics', 'info@pharma.fi', 4),
('Emergency Services', 'contact@ems.fi', 4),
('Dental Care Ltd', 'info@dental.fi', 1),
('Diagnostics Lab', 'support@lab.fi', 2);

-- Employees
INSERT INTO Employee (Email, Name, DepID) VALUES
('antti@hospital.fi', 'Dr. Antti', 1),
('dora@hospital.fi', 'Dr. Dora', 1),
('parsa@hospital.fi', 'Parsa', 2),
('mikko@hospital.fi', 'Mikko', 1),
('laura@hospital.fi', 'Laura', 1),
('jani@hospital.fi', 'Jani', 1),
('sara@hospital.fi', 'Sara', 2),
('tiina@hospital.fi', 'Tiina', 2),
('pekka@hospital.fi', 'Pekka', 2),
('otto@hospital.fi', 'Otto', 3),
('emma@hospital.fi', 'Emma', 3),
('noora@hospital.fi', 'Noora', 3),
('ville@hospital.fi', 'Ville', 4),
('joni@hospital.fi', 'Joni', 4),
('eeva@hospital.fi', 'Eeva', 4),
('markus@hospital.fi', 'Markus', 1),
('henna@hospital.fi', 'Henna', 2),
('joel@hospital.fi', 'Joel', 3);

-- Projects
INSERT INTO Project (Name, Budget, CID, StartDate, Deadline) VALUES
('Electronic Health Records System', 1000000, 1, '2025-01-01', '2025-12-31'),
('Smart Patient Monitoring', 500000, 2, '2025-03-01', '2025-10-01'),
('AI Diagnosis Platform', 750000, 3, '2025-02-01', '2025-11-30'),
('Cybersecurity for Patient Data', 300000, 4, '2025-04-15', '2025-09-30'),
('Mobile Health App', 150000, 5, '2025-05-01', '2025-08-15'),
('Cloud Migration for Records', 900000, 6, '2025-01-20', '2025-12-01'),
('Medical Logistics Optimization', 400000, 7, '2025-03-10', '2025-10-20');

-- Roles
INSERT INTO Role (Name) VALUES
('Medical IT Specialist'),
('Healthcare Manager');

-- EmployeeRole
INSERT INTO EmployeeRole (EmpID, RoleID, Description) VALUES
-- IT / medical tech staff
(1, 1, 'EHR Backend Specialist'),
(2, 1, 'Monitoring Systems Engineer'),
(4, 1, 'Fullstack Health Systems Dev'),
(5, 1, 'Mobile Health Developer'),
(6, 1, 'QA for Medical Software'),
(7, 1, 'Healthcare Data Engineer'),
(8, 1, 'Cloud Infrastructure Engineer'),
(9, 1, 'DevOps for Hospital Systems'),
(10, 1, 'AI Diagnostics Specialist'),
(11, 1, 'Clinical Systems Developer'),
(12, 1, 'Billing Systems Engineer'),
(13, 1, 'Data Integration Specialist'),

-- management/admin
(3, 2, 'Hospital Admin Manager'),
(14, 2, 'Research Program Manager'),
(15, 2, 'Project Manager'),
(16, 2, 'IT Team Lead');

-- UserGroups
INSERT INTO UserGroup (Name) VALUES
('System Admins'),
('Medical IT Team'),
('Hospital Management'),
('Billing Team');

-- UserGroupMember
INSERT INTO UserGroupMember (GrID, EmpID) VALUES
(1, 1),
(1, 3),

(2, 1),
(2, 2),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(2, 8),
(2, 9),
(2, 10),

(3, 3),
(3, 14),
(3, 15),
(3, 16),

(4, 10),
(4, 11);

-- Works
INSERT INTO Works (PrID, EmpID, Started) VALUES
(1, 1, '2025-01-05'),
(1, 2, '2025-01-10'),
(1, 4, '2025-01-12'),
(1, 7, '2025-01-15'),

(2, 3, '2025-03-05'),
(2, 5, '2025-03-06'),
(2, 6, '2025-03-07'),

(3, 8, '2025-02-05'),
(3, 9, '2025-02-10'),

(4, 10, '2025-04-20'),
(4, 11, '2025-04-22'),

(5, 12, '2025-05-03'),
(5, 13, '2025-05-05'),

(6, 14, '2025-01-25'),
(6, 15, '2025-02-01'),

(7, 16, '2025-03-15'),
(7, 2, '2025-03-18');




-- ============================================================
-- ROLE ACCESS DEMONSTRATION
-- ============================================================


--SET ROLE antti;

-- Allowed
--SELECT * FROM Customer;
--SELECT * FROM Location;

-- Not allowed 
--SELECT * FROM Employee;

--SET ROLE dora;

-- Allowed
--SELECT * FROM Employee;

--INSERT INTO Department (Name, LID)
--VALUES ('Finance', 1);

--UPDATE Employee
--SET Name = 'Alice Updated'
--WHERE EmpID = 1;

--INSERT INTO Project (Name, Budget, CID)
--VALUES ('AI System', 200000, 1);

-- Not allowed 
--DELETE FROM Employee WHERE EmpID = 1;

--CREATE ROLE test_role;



--RESET ROLE;

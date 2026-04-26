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

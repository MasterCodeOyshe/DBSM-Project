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

CREATE TABLE Location (
    LID      SERIAL       PRIMARY KEY,
    Address  VARCHAR(255) NOT NULL,
    Country  VARCHAR(100) NOT NULL DEFAULT 'Finland'
);

CREATE TABLE Department (
    DepID  SERIAL       PRIMARY KEY,
    Name   VARCHAR(100) NOT NULL UNIQUE,
    LID    INT          NOT NULL,

    CONSTRAINT fk_department_location
        FOREIGN KEY (LID) REFERENCES Location(LID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Customer (
    CID    SERIAL       PRIMARY KEY,
    Name   VARCHAR(150) NOT NULL,
    Email  VARCHAR(255) NOT NULL UNIQUE,
    LID    INT          NOT NULL,

    CONSTRAINT fk_customer_location
        FOREIGN KEY (LID) REFERENCES Location(LID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_customer_email CHECK (Email LIKE '%@%')
);

CREATE TABLE Employee (
    EmpID  SERIAL       PRIMARY KEY,
    Email  VARCHAR(255) NOT NULL UNIQUE,
    Name   VARCHAR(150) NOT NULL,
    DepID  INT          NOT NULL,

    CONSTRAINT fk_employee_department
        FOREIGN KEY (DepID) REFERENCES Department(DepID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_employee_email CHECK (Email LIKE '%@%')
);

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

    CONSTRAINT chk_project_budget CHECK (Budget > 0),

    CONSTRAINT chk_project_dates CHECK (Deadline IS NULL OR Deadline >= StartDate)
);

CREATE TABLE Role (
    RoleID  SERIAL       PRIMARY KEY,
    Name    VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE UserGroup (
    GrID  SERIAL       PRIMARY KEY,
    Name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Works (
    PrID    INT  NOT NULL,
    EmpID   INT  NOT NULL,
    Started DATE NOT NULL DEFAULT CURRENT_DATE,

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

CREATE TABLE EmployeeRole (
    EmpID       INT          NOT NULL,
    RoleID      INT          NOT NULL,
    Description VARCHAR(500) DEFAULT 'No description provided',

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

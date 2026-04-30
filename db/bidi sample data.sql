INSERT INTO Location (Address, Country) VALUES
    ('Lappeenranta, Skinnarilankatu 34', 'Finland'),
    ('Helsinki, Mannerheimintie 12',     'Finland'),
    ('Tampere, Hatanpään valtatie 24',   'Finland');

INSERT INTO Department (Name, LID) VALUES
    ('HR',               1),
    ('Software',         1),
    ('Data',             2),
    ('ICT',              2),
    ('Customer Support', 3);

INSERT INTO Customer (Name, Email, LID) VALUES
    ('MediCare Systems Oy',      'contact@medicare.fi',      1),
    ('HealthBridge Finland',     'info@healthbridge.fi',     2),
    ('Nordic Health Solutions',  'hello@nordichealth.fi',    2),
    ('Tampere University Hospital', 'projects@tays.fi',      3),
    ('DigiHealth Group',         'admin@digihealth.fi',      1),
    ('Finnish Medical Institute','fmi@fmi.fi',               3);

INSERT INTO Employee (Email, Name, DepID) VALUES
    ('anna.makinen@bidi.fi',     'Anna Mäkinen',     1),
    ('jukka.virtanen@bidi.fi',   'Jukka Virtanen',   1),
    ('sofia.laine@bidi.fi',      'Sofia Laine',      2),
    ('mikko.korhonen@bidi.fi',   'Mikko Korhonen',   2),
    ('aleksi.nieminen@bidi.fi',  'Aleksi Nieminen',  2),
    ('laura.heikkinen@bidi.fi',  'Laura Heikkinen',  3),
    ('pekka.hamalainen@bidi.fi', 'Pekka Hämäläinen', 3),
    ('hanna.järvinen@bidi.fi',   'Hanna Järvinen',   4),
    ('timo.lehtinen@bidi.fi',    'Timo Lehtinen',    4),
    ('paula.koskinen@bidi.fi',   'Paula Koskinen',   5),
    ('risto.mäkela@bidi.fi',     'Risto Mäkelä',     5),
    ('erika.salo@bidi.fi',       'Erika Salo',       3);

INSERT INTO Role (Name) VALUES
    ('Project Manager'),
    ('Lead Developer'),
    ('Data Analyst'),
    ('QA Engineer'),
    ('System Architect'),
    ('Support Specialist');

INSERT INTO UserGroup (Name) VALUES
    ('Tech Team'),
    ('Management'),
    ('Data Team'),
    ('Support Team');

INSERT INTO Project (Name, Budget, CID, StartDate, Deadline) VALUES
    ('Patient Records Portal',       125000.00, 1, '2024-01-15', '2024-12-31'),
    ('Hospital Analytics Dashboard', 210000.00, 2, '2024-03-01', '2025-06-30'),
    ('ICT Infrastructure Upgrade',    87500.00, 3, '2024-06-01', '2024-11-30'),
    ('Remote Patient Monitoring',    175000.00, 4, '2024-09-01', '2025-09-01'),
    ('Data Migration Project',        55000.00, 5, '2025-01-10', '2025-07-10'),
    ('Security Audit & Compliance',   42000.00, 6, '2025-02-01', '2025-08-01'),
    ('AI Diagnostics Platform',      320000.00, 2, '2025-03-15', NULL),
    ('Support Desk Modernisation',    68000.00, 4, '2024-11-01', '2025-11-01');

INSERT INTO Works (PrID, EmpID, Started) VALUES
    (1, 3, '2024-01-15'),
    (1, 4, '2024-01-15'),
    (1, 6, '2024-02-01'),
    (1, 8, '2024-02-01'),
    (2, 4, '2024-03-01'),
    (2, 6, '2024-03-01'),
    (2, 7, '2024-03-15'),
    (2, 9, '2024-04-01'),
    (4, 3, '2024-09-01'),
    (4, 5, '2024-09-01'),
    (4, 12,'2024-09-15'),
    (5, 6, '2025-01-10'),
    (5, 7, '2025-01-10'),
    (5, 12,'2025-01-20'),
    (6, 8, '2025-02-01'),
    (6, 9, '2025-02-01'),
    (7, 3, '2025-03-15'),
    (7, 5, '2025-03-15'),
    (7, 6, '2025-04-01'),
    (7, 7, '2025-04-01'),
    (8, 10,'2024-11-01'),
    (8, 11,'2024-11-01');

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

INSERT INTO UserGroupMember (GrID, EmpID) VALUES
    (1, 3),
    (1, 4),
    (1, 5),
    (1, 8),
    (1, 9),
    (2, 1),
    (2, 2),
    (3, 6),
    (3, 7),
    (3, 12),
    (4, 10),
    (4, 11);

DO $$
BEGIN
    BEGIN EXECUTE 'DROP OWNED BY antti CASCADE'; EXCEPTION WHEN undefined_object THEN NULL; END;
    BEGIN EXECUTE 'DROP OWNED BY dora CASCADE';  EXCEPTION WHEN undefined_object THEN NULL; END;
    BEGIN EXECUTE 'DROP OWNED BY parsa CASCADE'; EXCEPTION WHEN undefined_object THEN NULL; END;
END $$;
DROP USER IF EXISTS antti;
DROP USER IF EXISTS dora;
DROP USER IF EXISTS parsa;
DROP ROLE IF EXISTS db_employee;
DROP ROLE IF EXISTS db_manager;
DROP ROLE IF EXISTS db_admin;
DROP ROLE IF EXISTS db_readonly;

CREATE ROLE db_employee;
CREATE ROLE db_manager;
CREATE ROLE db_admin;
CREATE ROLE db_readonly;

GRANT SELECT ON Customer, Location TO db_employee;
GRANT SELECT, INSERT, UPDATE ON Department, Employee, Customer,
      EmployeeRole, Location, Project, Works TO db_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO db_manager;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO db_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db_readonly;

CREATE USER antti  WITH PASSWORD 'antti123';
CREATE USER dora   WITH PASSWORD 'dora123';
CREATE USER parsa  WITH PASSWORD 'parsa123';

GRANT db_employee TO antti;
GRANT db_manager  TO dora;
GRANT db_admin    TO parsa;

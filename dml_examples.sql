-- ============================================================
-- BiDi Database System - DML Examples
-- Member 3: Parsa Najafi
-- ============================================================

-- INSERT: Add a new employee to the Software department (DepID = 1)
INSERT INTO Employee (Email, Name, DepID)
VALUES ('new.hire@bidi.fi', 'Alex Virtanen', 1);


-- UPDATE: Increase project budget by 10% for project with PrID = 1
UPDATE Project
SET Budget = Budget * 1.10
WHERE PrID = 1;


-- DELETE: Remove an employee from a user group
DELETE FROM UserGroupMember
WHERE GrID = 1 AND EmpID = 2;
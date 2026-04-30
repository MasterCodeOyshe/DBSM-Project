INSERT INTO Employee (Email, Name, DepID)
VALUES ('new.hire@bidi.fi', 'Alex Virtanen', 1);


UPDATE Project
SET Budget = Budget * 1.10
WHERE PrID = 1;


DELETE FROM UserGroupMember
WHERE GrID = 1 AND EmpID = 9;
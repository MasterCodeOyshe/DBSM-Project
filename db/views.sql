CREATE OR REPLACE VIEW vw_active_projects AS
SELECT p.PrID,
       p.Name AS ProjectName,
       p.Budget,
       p.StartDate,
       p.Deadline,
       c.Name AS CustomerName,
       c.Email AS CustomerEmail,
       COUNT(w.EmpID) AS AssignedEmployees
FROM Project p
JOIN Customer c ON p.CID = c.CID
LEFT JOIN Works w ON p.PrID = w.PrID
WHERE p.Deadline IS NULL OR p.Deadline >= CURRENT_DATE
GROUP BY p.PrID,
         p.Name,
         p.Budget,
         p.StartDate,
         p.Deadline,
         c.Name,
         c.Email;
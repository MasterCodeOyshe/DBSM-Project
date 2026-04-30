CREATE TABLE IF NOT EXISTS DepartmentAuditLog (
    LogID      SERIAL PRIMARY KEY,
    EmpID      INT NOT NULL,
    OldDepID   INT NOT NULL,
    NewDepID   INT NOT NULL,
    ChangedAt  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_prevent_expired_project_assignment()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT Deadline FROM Project WHERE PrID = NEW.PrID) < CURRENT_DATE THEN
        RAISE EXCEPTION 'Cannot assign employee % to project %: deadline has passed.',
            NEW.EmpID, NEW.PrID;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_prevent_expired_assignment
BEFORE INSERT ON Works
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_expired_project_assignment();


CREATE OR REPLACE FUNCTION fn_prevent_empty_usergroup()
RETURNS TRIGGER AS $$
DECLARE
    member_count INT;
BEGIN
    SELECT COUNT(*) INTO member_count
    FROM UserGroupMember
    WHERE GrID = OLD.GrID;

    IF member_count <= 1 THEN
        RAISE EXCEPTION 'Cannot remove last member from UserGroup %.', OLD.GrID;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_prevent_empty_usergroup
BEFORE DELETE ON UserGroupMember
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_empty_usergroup();


CREATE OR REPLACE FUNCTION fn_audit_department_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.DepID <> OLD.DepID THEN
        INSERT INTO DepartmentAuditLog (EmpID, OldDepID, NewDepID)
        VALUES (OLD.EmpID, OLD.DepID, NEW.DepID);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_audit_department_change
AFTER UPDATE ON Employee
FOR EACH ROW
EXECUTE FUNCTION fn_audit_department_change();
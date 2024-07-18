-- Stored Procedure to update SubjectAllotments table based on SubjectRequest table

CREATE PROCEDURE UpdateSubjectAllotments
AS
BEGIN
    -- Declare variables to store the student ID and subject ID from SubjectRequest table
    DECLARE @studentId INT, @subjectId VARCHAR(10);

    -- Declare cursor to iterate through SubjectRequest table
    DECLARE subjectRequestCursor CURSOR FOR
    SELECT StudentId, SubjectId
    FROM SubjectRequest;

    -- Open the cursor
    OPEN subjectRequestCursor;

    -- Fetch the first record from the cursor
    FETCH NEXT FROM subjectRequestCursor INTO @studentId, @subjectId;

    -- Loop through the cursor until all records are processed
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student ID and subject ID exist in SubjectAllotments table
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentId = @studentId)
        BEGIN
            -- Check if the subject ID is different from the current valid subject ID
            IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentId = @studentId AND Is_Valid = 1 AND SubjectId <> @subjectId)
            BEGIN
                -- Update the current valid subject ID to invalid
                UPDATE SubjectAllotments SET Is_Valid = 0 WHERE StudentId = @studentId AND Is_Valid = 1;
            END;

            -- Insert the new subject ID as valid
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@studentId, @subjectId, 1);
        END
        ELSE
        BEGIN
            -- Insert the subject ID as valid
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@studentId, @subjectId, 1);
        END;

        -- Fetch the next record from the cursor
        FETCH NEXT FROM subjectRequestCursor INTO @studentId, @subjectId;
    END;

    -- Close the cursor
    CLOSE subjectRequestCursor;

    -- Deallocate the cursor
    DEALLOCATE subjectRequestCursor;
END;
GO
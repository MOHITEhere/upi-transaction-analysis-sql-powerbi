-- ============================================================
-- UPI TRANSACTIONS - DATA PROFILING
-- Author: Atharva
-- Dataset: 20,000 UPI Transaction Records | 20 Columns
-- Tool: SQL Server (SSMS)
-- ============================================================

-- -----------------------------------------------
-- STEP 1: Create Profiling Metadata Table
-- -----------------------------------------------

DROP TABLE IF EXISTS #temp_profile;

SELECT 
    column_name,
    ordinal_position,
    data_type,
    character_maximum_length
INTO #temp_profile
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'UPI_Transactions';

-- Add profiling columns
ALTER TABLE #temp_profile ADD maximum      NVARCHAR(MAX);
ALTER TABLE #temp_profile ADD minimum      NVARCHAR(MAX);
ALTER TABLE #temp_profile ADD nulls        INT;
ALTER TABLE #temp_profile ADD distinct_count INT;
ALTER TABLE #temp_profile ADD mean         FLOAT;
ALTER TABLE #temp_profile ADD median       FLOAT;
ALTER TABLE #temp_profile ADD mode         NVARCHAR(MAX);
ALTER TABLE #temp_profile ADD SD           FLOAT;
ALTER TABLE #temp_profile ADD zero_values  INT;

-- -----------------------------------------------
-- STEP 2: Dynamic Profiling Loop
-- -----------------------------------------------

DECLARE @i INT = 1, @j INT;
SET @j = (SELECT MAX(ordinal_position) FROM #temp_profile);

DECLARE @columnname NVARCHAR(MAX), @datatype NVARCHAR(MAX), @sql NVARCHAR(MAX);

WHILE @i <= @j
BEGIN
    SELECT @columnname = column_name, @datatype = data_type
    FROM #temp_profile
    WHERE ordinal_position = @i;

    -- Nulls and distinct count for ALL column types
    SET @sql = 'UPDATE #temp_profile SET
        nulls          = (SELECT COUNT(*) FROM UPI_Transactions WHERE ' + @columnname + ' IS NULL),
        distinct_count = (SELECT COUNT(DISTINCT ' + @columnname + ') FROM UPI_Transactions)
    WHERE ordinal_position = ' + CAST(@i AS VARCHAR);
    EXEC(@sql);

    -- NUMERIC columns
    IF @datatype IN ('int','float','real','decimal','numeric','money','smallint','tinyint','bigint')
    BEGIN
        SET @sql = 'UPDATE #temp_profile SET
            maximum     = CAST((SELECT MAX(' + @columnname + ') FROM UPI_Transactions) AS NVARCHAR(MAX)),
            minimum     = CAST((SELECT MIN(' + @columnname + ') FROM UPI_Transactions) AS NVARCHAR(MAX)),
            mean        = (SELECT AVG(CAST(' + @columnname + ' AS FLOAT)) FROM UPI_Transactions),
            SD          = (SELECT STDEV(' + @columnname + ') FROM UPI_Transactions),
            zero_values = (SELECT COUNT(*) FROM UPI_Transactions WHERE ' + @columnname + ' = 0)
        WHERE ordinal_position = ' + CAST(@i AS VARCHAR);
        EXEC(@sql);

        -- Mode
        SET @sql = 'UPDATE #temp_profile SET mode = (
            SELECT STRING_AGG(CAST(' + @columnname + ' AS NVARCHAR(MAX)), '', '') FROM (
                SELECT ' + @columnname + ', DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) DR
                FROM UPI_Transactions GROUP BY ' + @columnname + '
            ) x WHERE DR = 1
        ) WHERE ordinal_position = ' + CAST(@i AS VARCHAR);
        EXEC(@sql);

        -- Median (manual odd/even logic)
        DROP TABLE IF EXISTS #temp_median;
        SET @sql = 'SELECT ' + @columnname + ', ROW_NUMBER() OVER(ORDER BY ' + @columnname + ') rn
                    INTO #temp_median FROM UPI_Transactions WHERE ' + @columnname + ' IS NOT NULL';
        EXEC(@sql);

        DECLARE @l INT, @m INT, @n INT, @x FLOAT;
        SET @l = (SELECT MAX(rn) FROM #temp_median);
        SET @m = @l % 2;
        SET @n = @l / 2;

        IF @m = 0  -- Even: average of two middle values
        BEGIN
            SET @sql = 'SELECT @x = AVG(CAST(' + @columnname + ' AS FLOAT)) FROM #temp_median WHERE rn IN (' + CAST(@n AS VARCHAR) + ',' + CAST(@n+1 AS VARCHAR) + ')';
            EXEC sp_executesql @sql, N'@x FLOAT OUTPUT', @x OUTPUT;
        END
        IF @m <> 0  -- Odd: exact middle value
        BEGIN
            SET @sql = 'SELECT @x = CAST(' + @columnname + ' AS FLOAT) FROM #temp_median WHERE rn = ' + CAST(@n+1 AS VARCHAR);
            EXEC sp_executesql @sql, N'@x FLOAT OUTPUT', @x OUTPUT;
        END

        UPDATE #temp_profile SET median = @x WHERE ordinal_position = @i;
        DROP TABLE IF EXISTS #temp_median;
    END

    -- DATE columns
    IF @datatype IN ('date','datetime','datetime2','smalldatetime')
    BEGIN
        SET @sql = 'UPDATE #temp_profile SET
            maximum     = CAST((SELECT MAX(' + @columnname + ') FROM UPI_Transactions) AS NVARCHAR(MAX)),
            minimum     = CAST((SELECT MIN(' + @columnname + ') FROM UPI_Transactions) AS NVARCHAR(MAX)),
            zero_values = (SELECT COUNT(*) FROM UPI_Transactions WHERE ' + @columnname + ' = ''1900-01-01'')
        WHERE ordinal_position = ' + CAST(@i AS VARCHAR);
        EXEC(@sql);

        SET @sql = 'UPDATE #temp_profile SET mode = (
            SELECT STRING_AGG(CAST(' + @columnname + ' AS NVARCHAR(MAX)), '', '') FROM (
                SELECT ' + @columnname + ', DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) DR
                FROM UPI_Transactions GROUP BY ' + @columnname + '
            ) x WHERE DR = 1
        ) WHERE ordinal_position = ' + CAST(@i AS VARCHAR);
        EXEC(@sql);
    END

    -- VARCHAR / TEXT columns
    IF @datatype IN ('varchar','nvarchar','text','char','nchar')
    BEGIN
        SET @sql = 'UPDATE #temp_profile SET
            maximum     = CAST((SELECT MAX(' + @columnname + ') FROM UPI_Transactions) AS NVARCHAR(MAX)),
            minimum     = CAST((SELECT MIN(' + @columnname + ') FROM UPI_Transactions) AS NVARCHAR(MAX)),
            zero_values = (SELECT COUNT(*) FROM UPI_Transactions WHERE ' + @columnname + ' = ''0'')
        WHERE ordinal_position = ' + CAST(@i AS VARCHAR);
        EXEC(@sql);

        SET @sql = 'UPDATE #temp_profile SET mode = (
            SELECT STRING_AGG(' + @columnname + ', '', '') FROM (
                SELECT ' + @columnname + ', DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) DR
                FROM UPI_Transactions GROUP BY ' + @columnname + '
            ) x WHERE DR = 1
        ) WHERE ordinal_position = ' + CAST(@i AS VARCHAR);
        EXEC(@sql);
    END

    SET @i = @i + 1;
END

-- -----------------------------------------------
-- STEP 3: View Final Profile Report
-- -----------------------------------------------

SELECT 
    column_name      AS [Column],
    data_type        AS [Type],
    distinct_count   AS [Distinct Values],
    nulls            AS [Nulls],
    zero_values      AS [Zero/Default],
    minimum          AS [Min],
    maximum          AS [Max],
    ROUND(mean, 2)   AS [Mean],
    ROUND(median, 2) AS [Median],
    mode             AS [Mode],
    ROUND(SD, 2)     AS [Std Dev]
FROM #temp_profile
ORDER BY ordinal_position;

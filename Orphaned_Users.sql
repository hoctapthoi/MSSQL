CREATE TABLE #TempResults (DatabaseName NVARCHAR(255), PrincipalName NVARCHAR(255), AlterCommand NVARCHAR(255));

DECLARE @DatabaseName NVARCHAR(255);
DECLARE db_cursor CURSOR FOR
SELECT name FROM sys.databases WHERE state_desc = 'ONLINE';

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @DynamicSQL NVARCHAR(MAX);
    SET @DynamicSQL = N'
        USE [' + @DatabaseName + '];
        INSERT INTO #TempResults (DatabaseName, PrincipalName, AlterCommand)
        SELECT ''' + @DatabaseName + ''', name, ''USE [' + @DatabaseName + ']; DROP USER '' + QUOTENAME(name) + '';'' + CHAR(13) + CHAR(10)
        FROM sys.database_principals p
        WHERE p.type IN (''G'', ''S'', ''U'')
          AND p.sid NOT IN (SELECT sid FROM sys.server_principals)
          AND p.name NOT IN (''dbo'', ''guest'', ''INFORMATION_SCHEMA'', ''sys'', ''MS_DataCollectorInternalUser'')';

    EXEC sp_executesql @DynamicSQL;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

SELECT * FROM #TempResults
ORDER BY DatabaseName;

DROP TABLE #TempResults;

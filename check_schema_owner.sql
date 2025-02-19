
CREATE TABLE #SchemaOwners (
    DatabaseName NVARCHAR(128),
    SchemaName NVARCHAR(128),
    SchemaOwner NVARCHAR(128)
);


EXEC sp_MSForEachDB 
'USE [?];
INSERT INTO #SchemaOwners (DatabaseName, SchemaName, SchemaOwner)
SELECT 
    DB_NAME() AS DatabaseName, 
    s.name AS SchemaName, 
    u.name AS SchemaOwner
FROM 
    sys.schemas s
JOIN 
    sys.database_principals u ON s.principal_id = u.principal_id;';


SELECT * FROM #SchemaOwners;

DROP TABLE #SchemaOwners;

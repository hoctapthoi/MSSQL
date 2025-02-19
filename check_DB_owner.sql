create table #T1 (
	[Database Name] nvarchar(128),
	[Database User Name]  nvarchar(128),
	[Database Role]  nvarchar(128))
EXEC sp_MSForEachDB 
'USE [?];
insert into #T1
SELECT 
    ''?'' AS [Database Name], 
    su1.name AS [Database User Name], 
    su2.name AS [Database Role] 

FROM 
    [?].sys.database_role_members r 
INNER JOIN 
    [?]..sysusers su1 ON su1.[uid] = r.member_principal_id 
INNER JOIN 
    [?]..sysusers su2 ON su2.[uid] = r.role_principal_id 
WHERE 
    su2.name = ''db_owner'' 
    AND su1.name NOT IN (''dbo'')';

select * from #T1;
drop table #T1
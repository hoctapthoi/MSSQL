--Database Backups for all databases For Previous Week 
--------------------------------------------------------------------------------- 
USE MSDB
GO
SELECT 
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   backupset.database_name, 
   backupset.backup_start_date, 
   backupset.backup_finish_date, 
   backupset.expiration_date, 
   CASE backupset.type 
      WHEN 'D' THEN 'Database' 
      WHEN 'L' THEN 'Log' 
      END AS backup_type, 
   backupset.backup_size, 
   backupmediafamily.logical_device_name, 
   backupmediafamily.physical_device_name, 
   backupset.name AS backupset_name, 
   backupset.description 
FROM 
   backupmediafamily 
   INNER JOIN backupset ON backupmediafamily.media_set_id = backupset.media_set_id 
WHERE 
   (CONVERT(datetime, backupset.backup_start_date, 102) >= GETDATE() - 7) 
  -- backupset.backup_start_date between '2024-09-22' and  '2024-09-23'
ORDER BY 
   backupset.database_name, 
   backupset.backup_finish_date DESC

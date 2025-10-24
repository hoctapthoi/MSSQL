# =============================================
# PowerShell Script: Export SQL Agent Jobs (Filtered)
# Exclude: *.Subplan_* jobs and syspolicy_purge_history
# Output: Single .sql file
# =============================================

# Load SQL Server SMO Assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

# Configuration
$serverName = "localhost"  # Thay đổi tên server
$outputFile = "C:\Backup\AllAgentJobs_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"

# Jobs to exclude (thêm/bớt theo nhu cầu)
$excludePatterns = @(
    "*.Subplan_*",              # Loại trừ tất cả Maintenance Plan subplans
    "syspolicy_purge_history"   # Loại trừ policy history job
)

# Connect to SQL Server
$server = New-Object Microsoft.SqlServer.Management.Smo.Server($serverName)
$jobServer = $server.JobServer

# Filter jobs - Loại trừ các jobs không mong muốn
$jobsToExport = @()
$excludedJobs = @()

foreach ($job in $jobServer.Jobs) {
    $shouldExclude = $false
    
    foreach ($pattern in $excludePatterns) {
        if ($job.Name -like $pattern) {
            $shouldExclude = $true
            $excludedJobs += $job.Name
            Write-Host "Excluding job: $($job.Name)" -ForegroundColor Yellow
            break
        }
    }
    
    if (-not $shouldExclude) {
        $jobsToExport += $job
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "Total jobs found: $($jobServer.Jobs.Count)" -ForegroundColor White
Write-Host "Jobs to export: $($jobsToExport.Count)" -ForegroundColor Green
Write-Host "Jobs excluded: $($excludedJobs.Count)" -ForegroundColor Yellow

if ($excludedJobs.Count -gt 0) {
    Write-Host "`nExcluded jobs list:" -ForegroundColor Yellow
    $excludedJobs | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkYellow }
}

Write-Host "`nStarting export..." -ForegroundColor Cyan

# Create output file with header
$header = @"
-- =============================================
-- SQL Server Agent Jobs - Complete Backup
-- Source Server: $serverName
-- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- Total Jobs Found: $($jobServer.Jobs.Count)
-- Jobs Exported: $($jobsToExport.Count)
-- Jobs Excluded: $($excludedJobs.Count)
-- =============================================
-- Excluded Patterns:
$(foreach ($pattern in $excludePatterns) { "-- - $pattern`n" })
-- =============================================

USE msdb;
GO

"@

$header | Out-File -FilePath $outputFile -Encoding UTF8

# Script each job
$jobCount = 0
foreach ($job in $jobsToExport) {
    $jobCount++
    Write-Host "Exporting job $jobCount of $($jobsToExport.Count): $($job.Name)" -ForegroundColor White
    
    # Add separator
    $separator = @"

-- =============================================
-- Job: $($job.Name)
-- Enabled: $($job.IsEnabled)
-- Category: $($job.Category)
-- Owner: $($job.OwnerLoginName)
-- Description: $($job.Description)
-- =============================================

"@
    $separator | Out-File -FilePath $outputFile -Append -Encoding UTF8
    
    # Check if job exists and delete
    $dropScript = @"
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'$($job.Name)')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'$($job.Name)';
    PRINT 'Deleted existing job: $($job.Name)';
END
GO

"@
    $dropScript | Out-File -FilePath $outputFile -Append -Encoding UTF8
    
    # Script the job
    try {
        $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
        $scripter.Options.ScriptDrops = $false
        $scripter.Options.IncludeHeaders = $false
        $scripter.Options.ToFileOnly = $false
        $scripter.Options.Permissions = $true
        $scripter.Options.DriAll = $true
        
        $jobScript = $scripter.Script($job)
        
        foreach ($line in $jobScript) {
            $line | Out-File -FilePath $outputFile -Append -Encoding UTF8
        }
        
        "GO`n" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    }
    catch {
        $errorMsg = "-- ERROR: Failed to script job '$($job.Name)': $($_.Exception.Message)"
        Write-Host $errorMsg -ForegroundColor Red
        $errorMsg | Out-File -FilePath $outputFile -Append -Encoding UTF8
    }
}

# Footer
$footer = @"

-- =============================================
-- Backup completed successfully
-- Total jobs exported: $jobCount
-- Excluded jobs: $($excludedJobs.Count)
-- =============================================
"@

$footer | Out-File -FilePath $outputFile -Append -Encoding UTF8

# Final summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Backup completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Output file: $outputFile" -ForegroundColor Cyan
Write-Host "Jobs exported: $jobCount" -ForegroundColor Green
Write-Host "Jobs excluded: $($excludedJobs.Count)" -ForegroundColor Yellow
Write-Host "File size: $([math]::Round((Get-Item $outputFile).Length / 1KB, 2)) KB" -ForegroundColor White

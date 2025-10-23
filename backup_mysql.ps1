$mysqlUser = "root"
$mysqlPassword = "123456"
$mysqlDir = "C:\Program Files\MySQL\MySQL Server 5.5\bin"
$tempDir = "C:\backup-sql"
$zipFileName = "C:\MySQLDump_\backup-sql-$(get-date -f yyyy-MM-dd-hh-mm).zip"

# Ensure temp directory exists
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

function dumpAllDatabases($user, $pass) {
    $databaseList = & "$mysqlDir\mysql.exe" -u"$user" -p"$pass" -e "SHOW DATABASES;" | Select-String -NotMatch "Database"

    foreach ($db in $databaseList) {
        $dbName = $db.ToString().Trim()
        if ($dbName -notin @("information_schema", "performance_schema", "mysql", "sys")) {
            Write-Host "Dumping database: $dbName"
            & "$mysqlDir\mysqldump.exe" -u"$user" -p"$pass" --single-transaction --skip-lock-tables --databases $dbName > "$tempDir\$dbName.sql"
        }
    }
}

function zipDatabaseDumps($source, $destination) {
    if (Test-Path $destination) { Remove-Item $destination }
    Add-Type -Assembly "System.IO.Compression.FileSystem"
    [IO.Compression.ZipFile]::CreateFromDirectory($source, $destination)
}

dumpAllDatabases $mysqlUser $mysqlPassword
zipDatabaseDumps $tempDir $zipFileName

Write-Host "✅ Backup complete: $zipFileName"

#put lots of sensitive data here and specify some directories
$mysqlUser = ""
$mysqlPassword = ""
$mysqlDir = "C:\Program Files\MySQL\MySQL Server 5.5\bin"
$tempDir = "C:\backup-sql"
$zipFileName = "C:\MySQLDump_/backup-sql-$(get-date -f yyyy-MM-dd-hh-mm).zip"


#fetch list of dbs and dump each db
function dumpAllDatabases($user, $pass) {
	$databaseList = mysql -u"$user" -p"$pass" -e "SHOW DATABASES"

	foreach ($db in $databaseList) {
    	mysqldump -u"$user" -p"$pass" --databases $db > "$tempDir\$db.sql"
	}
}

#zip the folder containing the databases
function zipDatabaseDumps($source, $destination) {
    If(Test-path $destination) {Remove-item $destination}
    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($Source, $destination) 
}


#so we've done all the magic, let's run it!!
mkdir $tempDir
dumpAllDatabases $mysqlUser $mysqlPassword
zipDatabaseDumps  $tempDir $zipFileName


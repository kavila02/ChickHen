#The purpose of this script is just to sync the database with the file system
$server = "KF-SQL1"
$user = "sa"
$pwd = "f1L3CA8"   
$dbname="ChickHen_DEV"
$DataSource = "Server=$server;User Id=$user;Password=$pwd;Initial Catalog=$dbname"

$currentPath = Split-Path $MyInvocation.MyCommand.Path

$FileLocation = "D:\inetpub\wwwroot\Dev Sites\ChickHen_DEV\solution\Attachments\Soonr Workplace\ChickHen Test"
$ExcludeFromSave = "D:\\inetpub\\wwwroot\\Dev Sites\\ChickHen_DEV"

$connection = new-object system.data.SqlClient.SQLConnection($DataSource);
$connection.Open();


$sqlFileCommand = new-object system.data.SqlClient.SQLCommand("", $connection);
$sqlFileCommand.CommandType = [System.Data.CommandType]::StoredProcedure
$sqlFileCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter(("FullName"), [Data.SQLDBType]::Varchar, 900))) | Out-Null
$sqlFileCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter(("Name"), [Data.SQLDBType]::Varchar, 250))) | Out-Null
$sqlFileCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter(("FolderID"), [Data.SQLDBType]::Int))) | Out-Null
$sqlFileCommand.CommandText = "Files_Insert"

$sqlFolderCommand = new-object system.data.SqlClient.SQLCommand("", $connection);
$sqlFolderCommand.CommandType = [System.Data.CommandType]::StoredProcedure
$sqlFolderCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter(("FullName"), [Data.SQLDBType]::Varchar, 900))) | Out-Null
$sqlFolderCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter(("Name"), [Data.SQLDBType]::Varchar, 250))) | Out-Null
$sqlFolderCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter(("ParentFolderID"), [Data.SQLDBType]::Int))) | Out-Null
$sqlFolderCommand.Parameters.Add("@ReturnValue", [System.Data.SqlDbType]::"Int")
$sqlFolderCommand.Parameters["@ReturnValue"].Direction = [System.Data.ParameterDirection]"ReturnValue"
 
$sqlFolderCommand.CommandText = "Folders_Insert"

function processFolder ([String]$folderLocation, [Int]$folderID)
{
    $files = Get-ChildItem $folderLocation | Where-Object {$_ -isnot [System.IO.DirectoryInfo]}
    foreach ($file in $files){
        if ($file -ne $null){
            #insert into database if not exists
            #Write-Host("Insert " + $file.FullName)
            $sqlFileCommand.Parameters[0].Value = $file.FullName -replace $ExcludeFromSave,""
            $sqlFileCommand.Parameters[1].Value = $file.Name
            $sqlFileCommand.Parameters[2].Value = $folderID
            $sqlFileCommand.ExecuteScalar()
        }
    }

    $folders = Get-ChildItem $folderLocation | Where-Object {$_ -is [System.IO.DirectoryInfo]}
    foreach ($folder in $folders){
        if ($folder -ne $null){
            #insert into database if not exists and get ID of folder
            #Write-Host ($folder.FullName + "\")
            $sqlFolderCommand.Parameters[0].Value = ($folder.FullName -replace $ExcludeFromSave,"") + "\"
            $sqlFolderCommand.Parameters[1].Value = $folder.Name
            $sqlFolderCommand.Parameters[2].Value = $folderID
            $sqlFolderCommand.ExecuteScalar()

            $newFolderID = [int]$sqlFolderCommand.Parameters["@ReturnValue"].Value

            #call function for this folder
            processFolder ($folder.FullName + "\") $newFolderID
        }
    }
}

processFolder $FileLocation 0

$connection.Close();
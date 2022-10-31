

#import-module ImportExcel
#import-module SqlServer
#import-module Posh-SSH

#Provide SQLServerName
$SQLServer = "covr-prod-eus.database.windows.net"
#Provide Database Name 
$DatabaseName = "BMS"
#Scripts Folder Path
$FolderPath  ="D:\data_extracts\external\sql_scripts\leaders_group"
#Output Folder Path
$OutputFilename = "D:\data_extracts\external\output\leaders_group\" + $(get-date -f yyyyMMdd)+'_covr_leadersgroup.csv'
#sftpserver = sftp.covertech.com
$EmailRecipient = @("greg.wellbrock@covrtech.com", "michelle.lowe@covrtech.com", "alicia.noyes@covrtech.com","kelly.hamer@covrtech.com")

$User = "reportuser"
$PasswordFile = "D:\data_extracts\external\credentials\password.txt"
$KeyFile = "D:\data_extracts\external\credentials\AES.key"
$key = Get-Content $KeyFile
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)



#Loop through the .sql files and run them
foreach ($filename in get-childitem -path $FolderPath -filter "*.sql") {
    $data = invoke-sqlcmd -ServerInstance $SQLServer -Database $DatabaseName -InputFile $filename.fullname -Credential $MyCredential -OutputAs DataRows
    #write-host $data
    $tablename = ($filename).BaseName
    write-host $tablename
    $data | Select-Object -Property * -Exclude RowError, RowState, Table, ItemArray, HasErrors | Export-Csv -Path $OutputFilename 
} 


Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "Leaders Group Extract for  $(get-date -f yyyyMMdd)" -Body "see attached"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename
#Set-SFTPItem -SessionId $SFTPSession.SessionId -Path $OutputFilename -Destination /morganstanley

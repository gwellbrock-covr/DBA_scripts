

#import-module ImportExcel
#import-module SqlServer
#import-module Posh-SSH

#Provide SQLServerName
$SQLServer = "covr-prod-eus.database.windows.net"
#Provide Database Name 
$DatabaseName = "CovrServices"
#Scripts Folder Path
$FolderPath  ="D:\data_extracts\external\sql_scripts\americo"
#sftpserver = sftp.covertech.com
$EmailRecipient = @("greg.wellbrock@covrtech.com","mike.shea@covrtech.com")
$SftpPath = '/Americo/Production'

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
    #Output Folder Path
    $OutputFilename = "D:\data_extracts\external\output\americo\americo_"+"_" + $(get-date -f MMddyyyy) + ".csv"
    $data | Select-Object -Property * -Exclude RowError, RowState, Table, ItemArray, HasErrors | Export-Csv -Path $OutputFilename 
    Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "Americo Reports $(get-date -f yyyyMMdd)" -Body "see attached"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename



    Import-Module Posh-SSH
 
    #Create Credentials
    $password = ConvertTo-SecureString '----password here----' -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ("covr.filedrop", $password)
    $Session = New-SFTPSession -Computername ftp.covrtech.com -credential $creds -port 9922
 
    # Upload the files to the SFTP path
    Set-SFTPItem -SessionId ($Session).SessionId -Path $OutputFilename   -Destination $SftpPath 
   
 
    #Disconnect all SFTP Sessions
    Get-SFTPSession | % { Remove-SFTPSession -SessionId ($_.SessionId) }
   

} 


#Set-SFTPItem -SessionId $SFTPSession.SessionId -Path $OutputFilename -Destination /morganstanley
 
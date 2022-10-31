

#import-module ImportExcel
#import-module SqlServer
#import-module Posh-SSH

#Provide SQLServerName
$SQLServer = "covr-prod-eus.database.windows.net"
#Provide Database Name 
$DatabaseName = "BMS"
#Scripts Folder Path
$FolderPath  ="D:\data_extracts\external\sql_scripts\lfg"
#sftpserver = sftp.covertech.com
$EmailRecipient = @("greg.wellbrock@covrtech.com")


$User = "reportuser"
$PasswordFile = "D:\data_extracts\external\credentials\password.txt"
$KeyFile = "D:\data_extracts\external\credentials\AES.key"
$key = Get-Content $KeyFile
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)
$SftpPath = '/CorvFin4SPO2LFD_Prod'



#Loop through the .sql files and run them
foreach ($filename in get-childitem -path $FolderPath -filter "*.sql") {
    $data = invoke-sqlcmd -ServerInstance $SQLServer -Database $DatabaseName -InputFile $filename.fullname -Credential $MyCredential -OutputAs DataRows
    #write-host $data
    $tablename = ($filename).BaseName
    write-host $tablename
    #Output Folder Path
    $OutputFilename = "D:\data_extracts\external\output\lfg\lfg_$tablename"+"_" + $(get-date -f MMddyyyy) + ".csv"
    $data | Select-Object -Property * -Exclude RowError, RowState, Table, ItemArray, HasErrors | Export-Csv -Path $OutputFilename
        #Create Credentials
    $password = ConvertTo-SecureString "Ac#3c7%1" -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ("CorvFin4SPO2LFD", $password)
    $Session = New-SFTPSession -Computername transfer.lfg.com -credential $creds -port 22
 
    # Upload the files to the SFTP path
    Set-SFTPItem -SessionId ($Session).SessionId -Path $OutputFilename   -Destination $SftpPath 
 
    #Disconnect all SFTP Sessions
    Get-SFTPSession | % { Remove-SFTPSession -SessionId ($_.SessionId) }

    Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "LFG Reports $(get-date -f yyyyMMdd)" -Body "see attached"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename

} 


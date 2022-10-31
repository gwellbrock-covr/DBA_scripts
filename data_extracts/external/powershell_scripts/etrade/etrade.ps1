


import-module ImportExcel
import-module SqlServer
import-module Posh-SSH

#Provide SQLServerName
$SQLServer = "covr-prod-eus.database.windows.net"
#Provide Database Name 
$DatabaseName = "BMS"
#Scripts Folder Path
$FilePath = "D:\data_extracts\external\sql_scripts\etrade\etrade.sql"
#Output Folder Path
$OutputFilename = "D:\data_extracts\external\output\etrade\consumer_journey_export_etrade_" + $(get-date -f yyyyMMdd) + ".csv"

$User = "reportuser"
$PasswordFile = "D:\data_extracts\external\credentials\password.txt"
$SftpPath = '/FileDrop/ETrade'
$KeyFile = "D:\data_extracts\external\credentials\AES.key"
$key = Get-Content $KeyFile
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)
#$EmailRecipient = @("greg.wellbrock@covrtech.com", "michelle.lowe@covrtech.com", "alicia.noyes@covrtech.com")


try {

    #Loop through the .sql files and run them

    $data = invoke-sqlcmd -ServerInstance $SQLServer -Database $DatabaseName -InputFile $Filepath -Credential $MyCredential -OutputAs DataRows
    #write-host $data

    $data | Select-Object -Property * -Exclude RowError, RowState, Table, ItemArray, HasErrors | Export-Csv -Path $OutputFilename 
    #Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "Illustration Reports $(get-date -f yyyyMMdd)" -Body "see attached"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename

    # Load the Posh-SSH module
    Import-Module Posh-SSH

    #Create Credentials    
    $password = ConvertTo-SecureString '45srgfg' -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ("covr.filedrop", $password)
    $Session = New-SFTPSession -Computername ftp.covrtech.com -credential $creds -port 9922
 
 
    # Upload the files to the SFTP path
    Set-SFTPItem -SessionId ($Session).SessionId -Path $OutputFilename   -Destination $SftpPath 
 
    #Disconnect all SFTP Sessions
    Get-SFTPSession | % { Remove-SFTPSession -SessionId ($_.SessionId) }
   

   # $EmailRecipient = @("greg.wellbrock@covrtech.com", "michelle.lowe@covrtech.com", "alicia.noyes@covrtech.com")
  #  Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "Citi Commissions for  $(get-date -f yyyyMMdd)" -Body "see attached"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename


}

catch {

    Send-MailMessage -To "greg.wellbrock@covrtech.com" -From noreply@covrtech.com  -Subject "etrade Extract Failed on $(get-date -f yyyyMMdd)" -Body "$PSItem.Exception.Message"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename

}
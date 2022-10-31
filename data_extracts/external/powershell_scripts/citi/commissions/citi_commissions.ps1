


import-module ImportExcel
import-module SqlServer
import-module Posh-SSH

#Provide SQLServerName
$SQLServer = "covr-prod-eus.database.windows.net"
#Provide Database Name 
$DatabaseName = "BMS"
#Scripts Folder Path
$FilePath = "D:\data_extracts\external\sql_scripts\citi\commissions\citi_commission_extract.sql"
#Output Folder Path
$OutputFilename = "D:\data_extracts\external\output\citi\COVRTECH_INBOUND_BILLING_RECON_" + $(get-date -f yyyyMMdd) + ".csv"
$OutputFilename2 = "D:\data_extracts\external\output\citi\COVRTECH_INBOUND_PAYMENT_RECON_" + $(get-date -f yyyyMMdd) + ".csv"
#$EmailRecipient = "greg.wellbrock@covrtech.com"
#$SftpPath = '/FileDrop/Citibank'
$EmailRecipient = @("greg.wellbrock@covrtech.com", "michelle.lowe@covrtech.com", "alicia.noyes@covrtech.com")


try {

    #Loop through the .sql files and run them

    $data = invoke-sqlcmd -ServerInstance $SQLServer -Database $DatabaseName -InputFile $Filepath -user ReportUser -Password "" -OutputAs DataRows
    #write-host $data

    $data | Select-Object -Property * -Exclude RowError, RowState, Table, ItemArray, HasErrors | Export-Csv -Path $OutputFilename 
    $data | Select-Object -Property * -Exclude RowError, RowState, Table, ItemArray, HasErrors | Export-Csv -Path $OutputFilename2 
    #Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "Illustration Reports $(get-date -f yyyyMMdd)" -Body "see attached"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename

    # Load the Posh-SSH module
   # Import-Module Posh-SSH
 
    #Create Credentials

 #  $password = ConvertTo-SecureString '$G$zgopd7W870DX^E2lwQ' -AsPlainText -Force
 #  $creds = New-Object System.Management.Automation.PSCredential ("covr.filedrop", $password)
 #  $Session = New-SFTPSession -Computername ftp.covrtech.com -credential $creds -port 9922
 #
 #
 #  # Upload the files to the SFTP path
 #  Set-SFTPItem -SessionId ($Session).SessionId -Path $OutputFilename   -Destination $SftpPath 
 #  Set-SFTPItem -SessionId ($Session).SessionId -Path $OutputFilename2   -Destination $SftpPath 
 #
 #  #Disconnect all SFTP Sessions
 #  Get-SFTPSession | % { Remove-SFTPSession -SessionId ($_.SessionId) }
   
Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "CITI commission Extract $(get-date -f yyyyMMdd)" -Body 'CITI!!!'   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename, $OutputFilename2
#Set-SFTPItem -SessionId $SFTPSession.SessionId -Path $OutputFilename -Destination /morganstanley


}

catch {

    Send-MailMessage -To "greg.wellbrock@covrtech.com" -From noreply@covrtech.com  -Subject "Citi Commission Extract Failed on $(get-date -f yyyyMMdd)" -Body "$PSItem.Exception.Message"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename

}
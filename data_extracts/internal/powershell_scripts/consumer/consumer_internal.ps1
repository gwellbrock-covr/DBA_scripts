

#import-module ImportExcel
#import-module SqlServer
#import-module Posh-SSH

#Provide SQLServerName
$SQLServer = "covr-prod-eus.database.windows.net"
#Provide Database Name 
$DatabaseName = "BMS"
#Scripts Folder Path
$FolderPath  ="D:\data_extracts\internal\sql_scripts\consumer\"
#Output Folder Path
$OutputFilename = "D:\data_extracts\internal\output\consumer\" + $(get-date -f yyyyMMdd)+'_consumer_extract_agencyname.xlsx'
$EmailRecipient = @("greg.wellbrock@covrtech.com", "todd.ewing@covrtech.com", "martha.kalen@covrtech.com")
$User = "reportuser"
$PasswordFile = "D:\data_extracts\internal\credentials\password.txt"
$KeyFile = "D:\data_extracts\internal\credentials\AES.key"
$key = Get-Content $KeyFile
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)




#Loop through the .sql files and run them
foreach ($filename in get-childitem -path $FolderPath -filter "*.sql") {
    $data = invoke-sqlcmd -ServerInstance $SQLServer -Database $DatabaseName -InputFile $filename.fullname -Credential $MyCredential -OutputAs DataRows
    #write-host $data
    $tablename = ($filename).BaseName
    write-host $tablename
    $data | Select-Object -Property * -Exclude RowError, RowState, Table, ItemArray, HasErrors | Export-Excel -Path $OutputFilename -AutoSize  -WorksheetName  $tablename -TableName  $tablename
} 


Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "Consumer Extract $(get-date -f yyyyMMdd)" -Body "All Consumer Data Since 2021"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename
#Set-SFTPItem -SessionId $SFTPSession.SessionId -Path $OutputFilename -Destination /morganstanley

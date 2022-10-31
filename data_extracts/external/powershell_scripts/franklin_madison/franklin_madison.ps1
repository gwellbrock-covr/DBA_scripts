
#import-module ImportExcel
#import-module SqlServer
#import-module Posh-SSH
#import-module PSPGP


#Provide SQLServerName
$SQLServer = "covr-prod-eus.database.windows.net"
#Provide Database Name 
$DatabaseName = "BMS"

#Scripts Folder Path
$FolderPath = "D:\data_extracts\external\sql_scripts\franklin_madison\"
New-Item -Path "D:\data_extracts\external\output\franklin_madison\" -Name "$(get-date -f yyyyMMdd)" -ItemType "directory"
#Output Folder Path
$OutputFolder = "D:\data_extracts\external\output\franklin_madison\$(get-date -f yyyyMMdd)\"
$OutputFilename = $OutputFolder + 'covr_consumer_extract_' + $(get-date -f yyyyMMdd) + '.csv'
$PGPPath = "D:\data_extracts\external\credentials\pgp\Acxiom-FM-2022 (2022 Partner PGP key)_0xC9061BF7_public.asc"
$User = "reportuser"
$PasswordFile = "D:\data_extracts\external\credentials\password.txt"
$KeyFile = "D:\data_extracts\external\credentials\AES.key"
$key = Get-Content $KeyFile
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)



#sftpserver = sftp.covertech.com
#$EmailRecipient = "greg.wellbrock@covrtech.com"

try {
    #Loop through the .sql files and run them
    foreach ($filename in get-childitem -path $FolderPath -filter "*.sql") {
        $data = invoke-sqlcmd -ServerInstance $SQLServer -Database $DatabaseName -InputFile $filename.fullname  -Credential $MyCredential -OutputAs DataRows
        #write-host $data
        $tablename = ($filename).BaseName
        write-host $tablename
        $data | Select-Object -Property * -Exclude RowError, RowState, Table, ItemArray, HasErrors | Export-Csv -Path $OutputFilename 
    } 

    Protect-PGP -FilePathPublic $PGPPath -FolderPath $OutputFolder -OutputFolderPath $OutputFolder

}



#Send-MailMessage -To $EmailRecipient -From noreply@covrtech.com  -Subject "Illustration Reports $(get-date -f yyyyMMdd)" -Body "see attached"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename
#Set-SFTPItem -SessionId $SFTPSession.SessionId -Path $OutputFilename -Destination /morganstanley
catch {
    Send-MailMessage -To "greg.wellbrock@covrtech.com" -From noreply@covrtech.com  -Subject "FranklinMadison Extract Failed on $(get-date -f yyyyMMdd)" -Body "$PSItem.Exception.Message"   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $OutputFilename

}
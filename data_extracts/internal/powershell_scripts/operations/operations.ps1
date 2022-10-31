
#Send-MailMessage -To greg.wellbrock@covrtech.com -From noreply@covrtech.com  -Subject "test" -Body "this is the body of e-mail" -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25
#Install-Module ImportExcel -Scope allusers
#Provide SQLServerName
$SQLServer ="covr-prod-eus.database.windows.net"
#Provide Database Name 
$DatabaseName ="BMS"
#Scripts Folder Path
$FolderPath ="D:\data_extracts\internal\sql_scripts\operations\"
$csvpath = "D:\data_extracts\internal\output\operations\"
$CSVOutPutPath = $csvpath+ $(get-date -f yyyyMMdd)+'\'
$excelpath = "D:\data_extracts\internal\output\operations" + $(get-date -f yyyyMMdd)+'_Operations_Reporting.xlsx'
$tolist = "ops-reports@covrtech.com"



#create folder
New-Item -Path $CSVOutPutPath  -ItemType Directory -Force

#
#Loop through the .sql files and run them
foreach ($filename in get-childitem -path $FolderPath -filter "*.sql")
{
    $User = "reportuser"
    $PasswordFile = "D:\data_extracts\internal\credentials\password.txt"
    $KeyFile = "D:\data_extracts\internal\credentials\AES.key"
    $key = Get-Content $KeyFile
    $MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)
   
write-host $password
$data = invoke-sqlcmd -ServerInstance $SQLServer -Database $DatabaseName -InputFile $filename.fullname -user ReportUser -credential $MyCredential
#Print file name which is executed
$savefilename =($filename).BaseName
$csvfilename = "$CSVOutPutPath" + "$savefilename.csv"
write-host $csvfilename
$data | Export-Csv -Path $csvfilename -Force -UseQuotes AsNeeded  
} 



#excel conversion


$path=$CSVOutPutPath #target folder
write-host $CSVOutPutPath
set-location $path;

$csvs = Get-ChildItem .\* -Include *.csv
$y=$csvs.Count
Write-Host "Detected the following CSV files: ($y)"


foreach ($csv in $csvs) {
    Write-Host " "$csv.Name
    import-csv $csv | Export-Excel -Path $excelpath -AutoSize  -WorksheetName $csv.Name  -TableName $csv.Name
}





Start-Sleep -s 10

#$tolist = "greg.wellbrock@covrtech.com"

$body = "Operations Reports"


Send-MailMessage -To $tolist -From noreply@covrtech.com  -Subject "Operations Reports $(get-date -f yyyyMMdd)" -Body $body   -SmtpServer "covrtech-com.mail.protection.outlook.com" -Port 25 -Attachments $excelpath


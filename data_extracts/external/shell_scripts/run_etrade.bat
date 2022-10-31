@echo off
 
"C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Unrestricted -Command ". 'D:\data_extracts\external\powershell_scripts\etrade\etrade.ps1'"
 
TIMEOUT /T 10
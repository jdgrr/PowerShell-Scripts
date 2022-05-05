#requires -version 5.1
<#
.SYNOPSIS
Scrambles a list of users' passwords
.NOTES
Version:        1.0
Author:         James Grimes
Last Modified:  05/02/2022
Notes:          This script may not function properly unless you're using Windows PowerShell 5.1
#>

#Necessary for password generation. Will not work if ran with a PowerShell version above 5.1
Add-Type -AssemblyName System.Web

Write-Host 'The column header should be Users and each username should be on a separate line'
Write-Host 'Before continuing verify that your csv is properly formatted'
Start-Sleep -Seconds 5

#Prompt the user to select the file containing the usernames
Add-Type -AssemblyName System.Windows.Forms
$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$fileBrowser.filter = 'Csv (*.csv)| *.csv'
[void]$fileBrowser.ShowDialog()

$filePath = $fileBrowser.FileName

if (!(Test-Path -Path $filePath)) {
    [System.Windows.Forms.MessageBox]::Show('Error: File not found')
    Exit
}

$userList = Import-Csv -Path "$FilePath"
$totalItems = $userList.Count
$currentItem = 0

Write-Host 'Looping...'
$userList.foreach{
    $accountName = $_.Users
    $newPassword = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 20 -Maximum 32), 3)
    $securePassword = ConvertTo-SecureString -AsPlainText "$newPassword" -Force
    Set-ADAccountPassword -Identity $accountName -Reset -NewPassword $securePassword
    Set-ADUser -Identity $accountName -ChangePasswordAtLogon $true
    Get-ADUser -Identity $accountName -Properties * | Select-Object SamAccountName, PasswordLastSet
    $CurrentItem++
    Write-Host "Changed $accountname's Password - $currentItem out of $totalItems passwords changed"
}

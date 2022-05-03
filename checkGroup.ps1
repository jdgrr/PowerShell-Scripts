#requires -version 5.1
<#
.SYNOPSIS
Checks a list of users to see whether they're in a group or not
.NOTES
Version:        1.0
Author:         James Grimes
Last Modified:  05/03/2022
Notes:          This script may not function properly unless you're using Windows PowerShell 5.1
#>

Write-Host 'The column header should be Users and each username should be on a seperate line'
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

$userList = Import-Csv -Path "$filePath"

$groupName = Read-Host 'Please enter the group name'

#Terminate if the specificed group doesn't exist
try {
    Get-ADGroup -Identity “$groupName”
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    [System.Windows.Forms.MessageBox]::Show("Error: $groupName does not exist")
    Exit
}

#Initalize arrays 
$usersInGroup = @()
$usersNotInGroup = @()

Write-Host 'Looping...'
$userList.foreach{
    $accountName = $_.Users
    $userGroups = (Get-ADUser -Identity $accountName -Properties memberOf | Select-Object memberOf).memberOf
    if ($usergroups -like "*$groupName*") {
        $usersInGroup += $accountName
        Write-Host "$accountName's in $groupName"
    }
    else {
        $usersNotInGroup += $accountName
        Write-Host "$accountName's not in $groupName"
    }
}
<#
.SYNOPSIS

This script is used to add the organization address to specific users.

#>
Import-Module ActiveDirectory

function RecurseGroups {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage="Please type the org group name you're looking for...")]
        [String]$groupName
    )
    
    $getGroup = Get-ADGroup -Filter "GroupCategory -eq 'Security' -and Name -eq '$($groupName)'"
    $getGroupMembers = $getGroup | Get-ADGroupMember -Recursive `
    | Select-Object SamAccountName -Unique

    Foreach ($member in $getGroupMembers) {
        Get-ADUser $member.SamAccountName -Properties City,Company,HomePage,PostalCode,st,State,StreetAddress `
        | Set-ADUser -City "Sacramento" -Company "Christian Brothers High School" -HomePage "https://www.cbhs-sacramento.org"`
        -PostalCode "95820" -State "CA" -StreetAddress "4315 Martin Luther King, Jr. Blvd." #-WhatIf
        # https://docs.microsoft.com/en-us/powershell/module/activedirectory/set-aduser?view=winserver2012r2-ps&redirectedfrom=MSDN
    }
    
}

RecurseGroups
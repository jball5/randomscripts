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
    | Select-Object SamAccountName -Unique -First 1

    Foreach ($member in $getGroupMembers) {
        Get-ADUser $member.SamAccountName -Properties *
    }
    
}

RecurseGroups
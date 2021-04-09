<#
.SYNOPSIS
This script allows you to cleanup the Microsoft Teams app and remove the cache for a user.

Modified from https://techcommunity.microsoft.com/t5/itops-talk-blog/powershell-basics-how-to-delete-microsoft-teams-cache-for-all/ba-p/1519118 
#>
If ($IsMacOS) {
    Get-ChildItem "~/Library/Application Support/Microsoft/Teams/*" -directory | `
    Where-Object name -in ('application cache','blob storage','databases','GPUcache','IndexedDB','Local Storage','tmp') | `
    ForEach-Object { 
        Remove-Item $_.FullName -Recurse -Force 
    }
} Else {
    Get-ChildItem "C:\Users\*\AppData\Roaming\Microsoft\Teams\*" -directory | `
    Where-Object name -in ('application cache','blob storage','databases','GPUcache','IndexedDB','Local Storage','tmp') | `
    ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
    }
}
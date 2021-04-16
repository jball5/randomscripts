<#
.SYNOPSIS
This script allows you to cleanup the Microsoft Teams app and remove the cache for a user.

Modified from https://techcommunity.microsoft.com/t5/itops-talk-blog/powershell-basics-how-to-delete-microsoft-teams-cache-for-all/ba-p/1519118 
#>
If ($IsMacOS) {
    $folder_path = "~/Library/Application Support/Microsoft/Teams/*"
} elseif ($IsWindows) {
    $folder_path = "C:\Users\*\AppData\Roaming\Microsoft\Teams\*"
}

Get-ChildItem $folder_path -directory | `
Where-Object name -in ('application cache','blob storage','databases','GPUcache','IndexedDB','Local Storage','tmp') | `
ForEach-Object { 
    Remove-Item $_.FullName -Recurse -Force
}
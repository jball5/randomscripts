#requires -version 3.0
#Remove-UserProfile.ps1
[cmdletbinding(SupportsShouldProcess)]
Param(
[Parameter(Position=0)]
[ValidateNotNullorEmpty()]
[int]$Days=45
)
Start-Transcript -Path U:\Scripts\ProfileCleanup.txt -Append
Write-Warning "Filtering for user profiles older than $Days days on $env:COMPUTERNAME"

$ProfileSearch = Get-ChildItem -Path C:\Users\ | Sort-Object -Property LastWriteTime | `
Where-Object {($_.LastWriteTime -lt $(Get-Date).Date.AddDays(-$Days)) -and ($_.Name -match "^\w\d\d\d\d\d$")}
Write-Host "Found $($ProfileSearch.Count) profiles to remove."
Pause
foreach ($item in $ProfileSearch) {
    
    $IndvProfile = Get-CimInstance win32_userprofile -Verbose | `
    Where-Object {($_.LocalPath -eq "C:\Users\$($item.Name)") -and ($_.Loaded -eq $false)}
    Write-Warning "Removing $($IndvProfile.LocalPath)"
    Remove-CimInstance -InputObject $IndvProfile -Verbose
    if (Test-Path -Path "C:\Users\$($item.Name)") {
        Remove-Item -Path "C:\Users\$($item.Name)" -Recurse -Force
    }

}
Write-Host "This script cleared $($ProfileSearch.Count) profiles."
Stop-Transcript
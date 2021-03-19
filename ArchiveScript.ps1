#!/usr/bin/env pwsh
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,HelpMessage="Please specify a location to search and archive...")]
    [string]$Location
)
Set-Location -Path $Location
$SixMonthsBack = (Get-Date).AddMonths(-6)
$Date = Get-Date -Format FileDate 
$Exclude = @("*.app","*.zip")

Start-Transcript -Path ./archive_$Date.txt -UseMinimalHeader

function Search-Files {
    
    Get-ChildItem -Path "$Location/*" -File -Exclude $Exclude | `
    Select-Object LastWriteTime, LastAccessTime, Name, FullName | `
    Sort-Object LastAccessTime -Descending | `
    Where-Object {$_.LastWriteTime -lt $SixMonthsBack} -OutVariable Global:GatheredFiles
    
    if ($Global:GatheredFiles.Count -gt 0) {
        for ($i = 0; $i -lt $Global:GatheredFiles.Count; $i++) {
            if ($Global:GatheredFiles.Name[$i] -match "([\[\]\/\&\:])") {
              $Global:GatheredFiles.Name[$i] = Rename-Item -Path $Global:GatheredFiles.FullName[$i] -NewName $($Global:GatheredFiles.Name[$i] -replace "([\[\]\/\&\:])","_")
            }
          }
    }
}

function Search-Folders {
    
    Get-ChildItem -Path "$Location/*" -Directory -Recurse | `
    Select-Object LastWriteTime, LastAccessTime, Name, FullName, Extension | `
    Sort-Object LastAccessTime -Descending | `
    Where-Object {($_.LastAccessTime -lt $SixMonthsBack) -and ($_.FullName -notlike "*.app/*") -and ($_.Extension -ne ".app")} -OutVariable Global:GatheredFolders
    
}

function Backup-Process {
    param (
        $FilesOrFolders
    )
    If ($null -ne $FilesOrFolders.Name) {
        Write-Host "Adding $($FilesOrFolders.Name) to 6moDownloadArchive.zip" -ForegroundColor Green
        try {
            Compress-Archive -Path $FilesOrFolders.Name -Update -CompressionLevel Optimal -DestinationPath ./6moDownloadArchive.zip
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            Compress-Archive -Path $FilesOrFolders.FullName -Update -CompressionLevel Optimal -DestinationPath ./6moDownloadArchive.zip
        }
        Remove-Item $FilesOrFolders.FullName -Recurse -Confirm:$false
    }
}

Backup-Process(Search-Files)
Backup-Process(Search-Folders)

Write-Host "Success! All files and folders are backed up and compressed." -ForegroundColor Green

Stop-Transcript
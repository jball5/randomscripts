#/usr/bin/env pwsh
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
    
    Get-ChildItem -File -Exclude $Exclude | `
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
    
    Get-ChildItem -Directory -Exclude $Exclude | `
    Select-Object LastWriteTime, LastAccessTime, Name | `
    Sort-Object LastAccessTime -Descending | `
    Where-Object {$_.LastAccessTime -lt $SixMonthsBack} -OutVariable Global:GatheredFolders
    
}
<#
function Rename-Files {
    param (
        $Global:GatheredFiles
    )
    ForEach ($file in $Global:GatheredFiles) {
        if ($file.Name -match "([\[\]\/\&\:])") {
            Rename-Item -Path $file.FullName -NewName $($file.Name -replace "([\[\]\/\&\:])","_")
            $Global:RenameHappened = 1
        }
    Return $Global:RenameHappened    
    }
}
#>
[void](Search-Files)
[void](Search-Folders)
#[void](Rename-Files (Search-Files))
<#
If ($Global:RenameHappened -eq 1) {
    Write-Host "File rename happened, running search again" -ForegroundColor Green
    [void](Search-Files)
}
#>
function Backup-Process {
    param (
        $FilesOrFolders
    )
    If ($null -ne $FilesOrFolders.Name) {
        Write-Host "Adding $($FilesOrFolders.Name) to 6moDownloadArchive.zip" -ForegroundColor Green
        Compress-Archive -Path $FilesOrFolders.Name -Update -CompressionLevel Optimal -DestinationPath ./6moDownloadArchive.zip
        Remove-Item $FilesOrFolders.Name   
    }
}

Backup-Process(Search-Files)
Backup-Process(Search-Folders)

Write-Host "Success! All files and folders are backed up and compressed." -ForegroundColor Green

<#
If ($null -ne $Global:GatheredFiles.Name) {
    Write-Host "Adding $($Global:GatheredFiles.Name) to 6moDownloadArchive.zip" -ForegroundColor Green
    Compress-Archive -Path $Global:GatheredFiles.Name -Update -CompressionLevel Optimal -DestinationPath ./6moDownloadArchive.zip
    Remove-Item $Global:GatheredFiles.Name
    Write-Host "Success! All files are backed up and compressed." -ForegroundColor Green
} Else {
    Write-Host "Success! All files are backed up and compressed." -ForegroundColor Green
}

If ($null -ne $Global:GatheredFolders.Name) {
    Write-Host "Adding $($Global:GatheredFolders.Name) to 6moDownloadArchive.zip" -ForegroundColor Green
    Compress-Archive -Path $Global:GatheredFolders.Name -Update -CompressionLevel Optimal -DestinationPath ./6moDownloadArchive.zip
    Remove-Item $Global:GatheredFolders.Name -Recurse -Confirm:$false
    Write-Host "Success! All folders are backed up and compressed." -ForegroundColor Green
} Else {
    Write-Host "Success! All folders are backed up and compressed." -ForegroundColor Green
}
#>
Stop-Transcript
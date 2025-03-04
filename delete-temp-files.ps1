$tempFilePath = $env:TEMP
$fileCount = 0
$folderCount = 0

Function Remove-Contents {
    param(
        [string]$currentFolder 
    )

    $files = Get-ChildItem -Path $currentFolder -File
    ForEach ($file in $files) {
        $retries = 5
        $retryCount = 0
        $deleted = $false
        while (-not $deleted -and $retryCount -lt $retries) {
            try {
                Remove-Item $file.FullName -Force
                $global:fileCount++
                $deleted = $true
            } catch {
                $retryCount++
                Write-Host "Retrying to delete file: $($file.FullName). Attempt $retryCount of $retries..."
                Start-Sleep -Seconds 2 # Wait 2 sec
            }
        }

        if (-not $deleted) {
            Write-Host "Failed to delete file: $($file.FullName) after $retries attempts."
        }
    }

    $folders = Get-ChildItem -Path $currentFolder -Directory
    ForEach ($folder in $folders) {
        Remove-Contents -currentFolder $folder.FullName
    }

    ForEach ($folder in $folders) {
        try {
            Remove-Item $folder.FullName -Recurse -Force
            $global:folderCount += 1
        } catch {
            Write-Host "Failed to delete folder: $($folder.FullName). It may be in use by another process."
        }
    }
}

Write-Host "Deleting temp files and folders from $($tempFilePath) ..."
Remove-Contents -currentFolder $tempFilePath
Write-Host "Deleted $fileCount temp files"
Write-Host "Deleted $folderCount temp folders"
Read-Host "Press Enter to exit"
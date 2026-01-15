$assetsDir = "d:\shruti\shruti\assets"
Get-ChildItem -Path $assetsDir -Recurse -Filter *.wav | ForEach-Object {
    $inputPath = $_.FullName
    $outputPath = [System.IO.Path]::ChangeExtension($inputPath, ".ogg")
    
    Write-Host "Converting $inputPath to $outputPath"
    
    # Run ffmpeg, suppress output (-v 0), overwrite (-y)
    $process = Start-Process -FilePath "ffmpeg" -ArgumentList "-i", "`"$inputPath`"", "-c:a", "libvorbis", "-q:a", "4", "`"$outputPath`"", "-y" -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -eq 0) {
        Remove-Item $inputPath
    } else {
        Write-Error "Failed to convert $inputPath"
    }
}
Write-Host "Audio conversion complete."

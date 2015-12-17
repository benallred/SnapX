Add-Type -AssemblyName "System.IO.Compression.FileSystem"

function BuildRelease([string]$releaseVersion, [int]$architecture)
{
    $compilerDir = "$env:ProgramFiles\AutoHotkey\Compiler"
    $releaseDir = "$(pwd)\Releases"
    $tmpDir = "$releaseDir\tmp"
    $zipFilePath = "$releaseDir\SnapX_$releaseVersion" + "_x$architecture.zip"
    
    if (!(Test-Path $tmpDir))
    {
        New-Item -type directory -path $tmpDir
    }
    
    & $compilerDir\Ahk2Exe.exe /in SnapX.ahk /out $tmpDir\SnapX.exe /icon SnapX.ico /bin "$compilerDir\Unicode $architecture-bit.bin"
    
    Start-Sleep -s 5 # just waiting for the .exe to appear (like the .zip file below) is a little premature because there is also a temporary file there with it for a little longer
    
    [IO.Compression.ZipFile]::CreateFromDirectory($tmpDir, $zipFilePath)
    
    while (!(Test-Path $zipFilePath))
    {
        Start-Sleep -m 250
    }
    
    Remove-Item -Path $tmpDir -Recurse
}

Write-Host "Specify release version"
$releaseVersion = Read-Host

$buildInfoFilePath = "Build.ahk"

if (Test-Path $buildInfoFilePath)
{
    Remove-Item -Path $buildInfoFilePath
}

Add-Content -Path $buildInfoFilePath -Value "Build := { version: `"$releaseVersion`" }"

BuildRelease $releaseVersion 64
BuildRelease $releaseVersion 32

# At some point, I may consider calling into Git to set a tag with $releaseVersion.
# I could also call the GitHub API and create the release (https://developer.github.com/v3/repos/releases/#create-a-release).
# For now, though, I'd like to keep these manual operations.
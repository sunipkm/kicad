# Make the "lite" installer, which downloads KiCad's libraries while it installs, into out\*.exe.
$ErrorActionPreference = 'Stop'
Set-Location C:\kwb
pwsh -NoProfile -File .\build.ps1 -Package -Arch x64 -BuildConfigName refresh-package -Lite
if( $LASTEXITCODE -ne 0 ) { throw "packaging failed ($LASTEXITCODE)" }

New-Item -ItemType Directory -Force "$env:GITHUB_WORKSPACE\out" | Out-Null
Copy-Item C:\kwb\.out\*-lite.exe "$env:GITHUB_WORKSPACE\out\"

$bin = 'C:\kwb\.out\x64-windows-Release\bin'
$shown = & "$bin\kicad-cli.exe" version
if( $LASTEXITCODE -ne 0 -or "$shown" -notmatch [regex]::Escape($env:KICAD_VERSION) ) {
    throw "kicad-cli does not run: $shown"
}
if( -not (Select-String -Path "$bin\*.dll" -Pattern 'RefreshLibraries' -SimpleMatch -Quiet) ) {
    throw "RefreshLibraries is not in this build"
}

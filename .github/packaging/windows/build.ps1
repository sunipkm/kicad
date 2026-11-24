# Build KiCad with the builder prepare.ps1 set up.
$ErrorActionPreference = 'Stop'
Set-Location C:\kwb
pwsh -NoProfile -File .\build.ps1 -Build -Arch x64 -BuildConfigName refresh-build
if( $LASTEXITCODE -ne 0 ) { throw "the build failed ($LASTEXITCODE)" }

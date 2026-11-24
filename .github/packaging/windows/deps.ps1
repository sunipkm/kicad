# Build KiCad's vcpkg packages into the binary cache (C:\vcache), in the compiler environment the
# builder uses, so that build.ps1 finds them there.
$ErrorActionPreference = 'Stop'
Set-Location C:\kwb
Import-Module C:\kwb\KiBuild -Force -DisableNameChecking
Set-Alias vswhere (Get-ChildItem C:\kwb\.support\vswhere*.exe | Select-Object -First 1).FullName -Scope Global
Set-MSVCEnvironment -Arch x64 -VersionMin 16.0 -VersionMax 17.99
if( -not $env:VSCMD_VER ) { throw "no Visual Studio environment" }

C:\kwb\vcpkg\vcpkg.exe install --vcpkg-root=C:\kwb\vcpkg --triplet x64-windows `
    --clean-after-build --x-manifest-root=C:\kwb\.build\kicad --x-install-root=C:\vinst
exit $LASTEXITCODE

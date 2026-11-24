# Fetch KiCad's Windows builder (WIN_BUILDER_COMMIT) into C:\kwb, its tools and its vcpkg, and put
# this checkout where it keeps KiCad's source (C:\kwb\.build\kicad). Short paths: Windows' limit.
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

git init -q C:\kwb
git -C C:\kwb fetch -q --depth 1 https://gitlab.com/kicad/packaging/kicad-win-builder.git $env:WIN_BUILDER_COMMIT
git -C C:\kwb checkout -q FETCH_HEAD

$version = "$env:KICAD_VERSION-$env:REFRESH"
foreach( $config in 'refresh-build', 'refresh-package' ) {
    (Get-Content "$PSScriptRoot\$config.json" -Raw).Replace('@VERSION@', $version) |
        Set-Content "C:\kwb\build-configs\$config.json"
}

# An existing source folder without a ref is taken as it is. Nothing of the libraries is built: the
# "lite" installer downloads them.
New-Item -ItemType Directory -Force C:\kwb\.build | Out-Null
git clone -q "$env:GITHUB_WORKSPACE" C:\kwb\.build\kicad
git -C C:\kwb\.build\kicad -c user.name=build -c user.email=build@localhost tag -f -a $version -m $version
foreach( $lib in 'symbols', 'footprints', 'packages3D', 'templates' ) {
    New-Item -ItemType Directory -Force "C:\kwb\.build\kicad-$lib" | Out-Null
}
New-Item -ItemType Directory -Force C:\vcache | Out-Null

$PSNativeCommandUseErrorActionPreference = $false
Set-Location C:\kwb

# The tools come from several sites, some of them flaky.
foreach( $try in 1..4 ) {
    pwsh -NoProfile -File .\build.ps1 -Init
    if( $LASTEXITCODE -eq 0 ) { break }
    if( $try -eq 4 ) { throw "build.ps1 -Init failed" }
    Start-Sleep -Seconds (30 * $try)
}

# Cloned here: when the builder does it, it forgets to use Visual Studio's CMake and Ninja.
git clone -q https://github.com/microsoft/vcpkg.git C:\kwb\vcpkg
pwsh -NoProfile -File .\build.ps1 -Config -VcpkgPath C:\kwb\vcpkg
pwsh -NoProfile -File .\build.ps1 -Vcpkg -Latest -Arch x64 -BuildConfigName refresh-build
if( $LASTEXITCODE -ne 0 -or -not (Test-Path C:\kwb\vcpkg\vcpkg.exe) ) { throw "vcpkg was not set up" }
Get-PSDrive -PSProvider FileSystem

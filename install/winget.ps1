$packages = @(
    "Kitware.CMake",
    "LLVM.LLVM",
    "Ninja-build.Ninja",
    "zig.zig",
    "CoreyButler.NVMforWindows",
    "JanDeDobbeleer.OhMyPosh",
    "sharkdp.bat",
    "VideoLAN.VLC",
    "Git.Git",
    "GitHub.cli",
    "BurntSushi.ripgrep.MSVC",
    "junegunn.fzf",
    "lsd-rs.lsd",
    "OpenJS.NodeJS",
    "ajeetdsouza.zoxide",
    "GnuWin32.GetText",
    "Microsoft.VisualStudio.2022.BuildTools", 
    "EclipseAdoptium.Temurin.21.JDK",
    "Composer.Composer",
    "windows-terminal-quake",
    "Microsoft.PowerToys",
    "BeyondCode.Herd"
);

Write-Host "Checking and installing packages..." -ForegroundColor Cyan
foreach ($package in $packages) {
    Write-Host "`n=== Processing $package ===" -ForegroundColor Cyan
    winget install --id $package --exact --source winget --accept-package-agreements --accept-source-agreements
}

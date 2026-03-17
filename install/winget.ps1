$packages = @(
    "Kitware.CMake",
    "Microsoft.VisualStudio.2022.BuildTools",
    "LLVM.clangd",
    "Oven-sh.Bun",
    "StartIsBack.StartAllBack",
    "RandyRants.SharpKeys",
    "OpenWhisperSystems.Signal",
    "Valve.Steam",
    "Insomnia.Insomnia",
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
    "AutoHotkey.AutoHotkey",
    "WinMerge.WinMerge",
    "junegunn.fzf",
    "lsd-rs.lsd",
    "Microsoft.PowerShell",
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

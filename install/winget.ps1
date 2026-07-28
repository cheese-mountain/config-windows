$packages = @(
    "Kitware.CMake",
    "Microsoft.VisualStudio.2022.BuildTools",
    "Python.Python.3.11",
    "Notion.Notion",
    "Doist.Todoist",
    "jqlang.jq",
    "LLVM.clangd",
    "Oven-sh.Bun",
    "RandyRants.SharpKeys",
    "OpenWhisperSystems.Signal",
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
    "Neovim.Neovim",
);

Write-Host "Checking and installing packages..." -ForegroundColor Cyan
foreach ($package in $packages) {
    Write-Host "`n=== Processing $package ===" -ForegroundColor Cyan
    winget install --id $package --exact --source winget --accept-package-agreements --accept-source-agreements
}

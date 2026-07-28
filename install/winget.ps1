$packages = @(
    "Kitware.CMake",
    "Microsoft.VisualStudio.2022.BuildTools",
    "LLVM.clangd",
    "Python.Python.3.11",
    "LLVM.LLVM",
    "Ninja-build.Ninja",
    "BurntSushi.ripgrep.MSVC",
    "Neovim.Neovim",
    "Notion.Notion",
    "Doist.Todoist",
    "jqlang.jq",
    "Oven-sh.Bun",
    "RandyRants.SharpKeys",
    "OpenWhisperSystems.Signal",
    "Insomnia.Insomnia",
    "zig.zig",
    "CoreyButler.NVMforWindows",
    "JanDeDobbeleer.OhMyPosh",
    "sharkdp.bat",
    "VideoLAN.VLC",
    "Git.Git",
    "GitHub.cli",
    "AutoHotkey.AutoHotkey",
    "WinMerge.WinMerge",
    "junegunn.fzf",
    "lsd-rs.lsd",
    "Microsoft.PowerShell",
    "OpenJS.NodeJS",
    "ajeetdsouza.zoxide",
    "GnuWin32.GetText",
    "EclipseAdoptium.Temurin.21.JDK",
    "Microsoft.PowerToys"
);

Write-Host "Checking and installing packages..." -ForegroundColor Cyan
foreach ($package in $packages) {
    Write-Host "`n=== Processing $package ===" -ForegroundColor Cyan

    # Cheap local check first - `winget list` hits only the installed-package
    # registry (no download/hash), so we skip before winget tries to upgrade.
    winget list --id $package --exact --accept-source-agreements | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  already installed, skipping" -ForegroundColor DarkGray
        continue
    }

    winget install --id $package --exact --source winget --accept-package-agreements --accept-source-agreements
}

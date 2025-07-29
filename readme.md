# Guide
Make sure all applications run as admin to not run into any issues

## Table of Contents

- [Getting Started](#getting-started)
- [Terminal Setup](#terminal-setup)
- [Keybindings](#keybindings)
- [VSCode](#vscode)

## Getting started

1. Install github cli & run gh auth login
2. Clone the repo: ```gh repo clone cheese-mountain/config```
3. Install all fonts under ./fonts

## General customization
1. Set #11111B as background
2. Hide desktop icons under view -> toggle desktop icons
3. Uncheck animate minimize closing of windows & shadow under Advanced System settings > Performance settings
4. Configure mydockfinder

### Terminal Setup

1. Install neovim, wezterm, wtq, fzf, latest powershell, windows terminal, Search Everything & oh my posh
2. Copy paste windows terminal settings from windows/terminal.json
3. Run ```Set-ExecutionPolicy RemoteSigned -Scope CurrentUser```
4. Run nvim $profile & insert ```. T:\path\to\this\repo\profile.ps1```
5. Run ```Install-Module PSEverything, "Terminal-Icons"```
6. Create wezterm config, ```ni -ItemType SymbolicLink -Path "$home\.config\.wezterm.lua" -Target "T:\path\to\this\repo\windows\wezterm.lua”```
7. Create wtq config, ```ni -ItemType SymbolicLink -Path "$home\.config\wtq.json" -Target "T:\path\to\this\repo\windows\wtq.json”```

### Keybindings

1. Install sharpkeys & autohotkey v2
2. Run sharpkeys & remap caps to esc
3. Open task scheduler with Win + R, 'taskschd.msc' > Create Task. Trigger should be when logged in & action is to execute ./hotkeys/build.exe

### VSCode

Either:
a) Login and it will auto sync for you or
b) copy settings under vscode/*.json

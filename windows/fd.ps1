# Repo directory picker. Dot-sourced by profile.ps1 for the interactive `fd`
# command, and by herdr-fd.ps1 for the herdr popup, so both share one definition.

function Select-RepoDir {
    Get-ChildItem -Path "$HOME\repos" -Directory |
        ForEach-Object { $_.FullName } |
        fzf `
            --preview 'lsd --color=always --icon=always {}' `
            --preview-window=right:50% `
            --height=80% `
            --border
}

function fd {
    # No Out-String on the fzf output: it appends CRLF, and Set-Location then
    # fails on the trailing newline. fzf's single-line output is already clean.
    $selectedDir = Select-RepoDir
    if ($selectedDir) {
        Set-Location $selectedDir
    }
}

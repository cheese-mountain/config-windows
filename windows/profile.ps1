# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Force Unix/Emacs keybindings for terminal navigation
Set-PSReadLineOption -EditMode Emacs

Set-Alias -Name vim -Value nvim

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
Set-Alias -Name cd -Value z

$omp_config = Join-Path $PSScriptRoot ".\oh-my-posh.json"
oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression

Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue

function ln {
    param(
        [Parameter(Mandatory=$true)]
        [string]$target,

        [Parameter(Mandatory=$true)]
        [string]$path
    )
    New-Item -ItemType SymbolicLink -Path $path -Target $target
}

function wp-pull-db {
    param(
        [Parameter(Mandatory=$true)]
        [string]$user,

        [Parameter(Mandatory=$true)]
        [string]$server,

        [Parameter(Mandatory=$true)]
        [string]$path,

        [string]$password,

        [string]$sshuser = $user
    )

    $db_dir = Join-Path $HOME "wordpress\db"
    if ( -not ( Test-Path $db_dir ) ) { New-Item -ItemType Directory -Path $db_dir -Force | Out-Null }

    $dest = Join-Path $db_dir "$user.db"
    $tmp = Join-Path $env:TEMP "wp-pull-db-$PID.sql"
    $pwfile = Join-Path $env:TEMP "wp-pull-pw-$PID.txt"

    # $path is the user's base dir: the dump is staged there and wp runs in $path/public_html.
    # Staging outside /tmp matters because CageFS/CloudLinux gives each user a private /tmp,
    # so a file written as $user would be invisible to a root scp session.
    $remote_dump = "$path/wp-pull-db-$PID.sql"
    $webroot = "$path/public_html"

    try {
        if ( $password ) {
            Set-Content -Path $pwfile -Value $password -NoNewline -Encoding utf8NoBOM
        }

        # base64 both layers so nothing has to survive PowerShell -> ssh -> sh -> su quoting
        $inner = "cd '$( $webroot.Replace( "'", "'\''" ) )' && wp db export --single-transaction --quick --skip-plugins --skip-themes '$remote_dump'"
        $inner_b64 = [Convert]::ToBase64String( [Text.Encoding]::UTF8.GetBytes( $inner ) )

        $script = @'
set -eu
target='__USER__'
inner='__INNER__'
me="$( whoami )"
if [ "$me" = "$target" ]; then
    echo "$inner" | base64 -d | sh
elif [ "$me" = 'root' ]; then
    su - "$target" -c "echo $inner | base64 -d | sh"
else
    echo "logged in as $me, cannot become $target without a password prompt" >&2
    exit 1
fi
chmod 600 '__DUMP__' 2>/dev/null || true
'@
        $script = $script.Replace( '__USER__', $user.Replace( "'", "'\''" ) ).Replace( '__INNER__', $inner_b64 ).Replace( '__DUMP__', $remote_dump )
        $b64 = [Convert]::ToBase64String( [Text.Encoding]::UTF8.GetBytes( $script ) )
        $remote_cmd = "echo $b64 | base64 -d | sh"

        # Out-Host keeps remote chatter off the pipeline so $dest is the only return value
        Write-Host "-> dumping database on $server as $user" -ForegroundColor Cyan
        if ( $password ) {
            plink -ssh -pwfile $pwfile "$sshuser@$server" $remote_cmd | Out-Host
        } else {
            ssh "$sshuser@$server" $remote_cmd | Out-Host
        }
        if ( $LASTEXITCODE -ne 0 ) { throw "remote dump failed" }

        Write-Host "-> downloading" -ForegroundColor Cyan
        if ( $password ) {
            pscp -q -pwfile $pwfile "${sshuser}@${server}:$remote_dump" $tmp
        } else {
            scp -q "${sshuser}@${server}:$remote_dump" $tmp
        }
        $copy_failed = $LASTEXITCODE -ne 0

        if ( $password ) {
            plink -ssh -pwfile $pwfile "$sshuser@$server" "rm -f '$remote_dump'" | Out-Host
        } else {
            ssh "$sshuser@$server" "rm -f '$remote_dump'" | Out-Host
        }
        if ( $copy_failed ) { throw "download failed" }

        if ( Test-Path $dest ) {
            $rotated = Join-Path $db_dir "$user-$( Get-Date -Format 'yyyy-MM-dd-HHmmss' ).sql"
            Move-Item $dest $rotated
            Write-Host "-> previous dump kept at $rotated" -ForegroundColor DarkGray
        }
        Move-Item $tmp $dest

        Write-Host "-> saved to $dest" -ForegroundColor Green
        return $dest
    }
    finally {
        Remove-Item $pwfile -ErrorAction SilentlyContinue
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

function wp-import-db {
    param(
        [Parameter(Mandatory=$true)]
        [string]$file,

        [string]$path = "."
    )

    if ( -not ( Test-Path $file ) ) { throw "no such dump: $file" }
    $file = ( Resolve-Path $file ).Path
    $backup = Join-Path $env:TEMP "wp-import-backup-$PID.sql"

    Push-Location $path
    try {
        $local_url = wp option get siteurl
        if ( $LASTEXITCODE -ne 0 ) { throw "not a WordPress install: $( Get-Location )" }

        Write-Host "-> backing up local database" -ForegroundColor Cyan
        wp db export $backup
        if ( $LASTEXITCODE -ne 0 ) { throw "local backup failed" }

        Write-Host "-> importing $file" -ForegroundColor Cyan
        wp db reset --yes
        wp db import $file
        if ( $LASTEXITCODE -ne 0 ) { throw "import failed, restore with: wp db import $backup" }

        $prod_url = wp option get siteurl
        if ( $prod_url -ne $local_url ) {
            Write-Host "-> $prod_url => $local_url" -ForegroundColor Cyan
            wp search-replace $prod_url $local_url --all-tables --precise --skip-columns=guid
        }
        wp cache flush

        Write-Host "done, backup at $backup" -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}

function wp-sync {
    param(
        [Parameter(Mandatory=$true)]
        [string]$user,

        [Parameter(Mandatory=$true)]
        [string]$server,

        [Parameter(Mandatory=$true)]
        [string]$remotepath,

        [string]$localpath = ".",

        [string]$password,

        [string]$sshuser = $user
    )

    $dump = wp-pull-db -user $user -server $server -path $remotepath -password $password -sshuser $sshuser
    wp-import-db -file $dump -path $localpath
}

# 'spektra' is the ~/.ssh/config alias for 86.107.103.225; the raw IP misses IdentityFile
function spktr-pull {
    wp-pull-db -user ahouseweb -server spektra -path /home/ahouseweb -sshuser root
}

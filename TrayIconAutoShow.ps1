# TrayIconAutoShow.ps1
# Windows 11: keep application tray icons visible using a 30-second registry check.
# Double-click Start.cmd to install/start, or Stop.cmd to stop and disable startup.
# Runs per user; no administrator privileges or external dependencies required.
[CmdletBinding()]
param(
    [ValidateSet('Install', 'Watch', 'Remove', 'Once')]
    [string]$Mode = 'Install'
)

$ErrorActionPreference = 'Stop'
$iconKey = 'HKCU:\Control Panel\NotifyIconSettings'
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$runName = 'TrayIconAutoShow'
$folder = Join-Path $env:LOCALAPPDATA 'TrayIconAutoShow'
$dest = Join-Path $folder 'TrayIconAutoShow.ps1'
$exe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$intervalSeconds = 30

function Set-TrayIconsVisible {
    if (-not (Test-Path -LiteralPath $iconKey)) { return 0 }
    $changed = 0
    foreach ($entry in (Get-ChildItem -LiteralPath $iconKey -ErrorAction SilentlyContinue)) {
        try {
            $current = (Get-ItemProperty -LiteralPath $entry.PSPath -Name 'IsPromoted' -ErrorAction SilentlyContinue).IsPromoted
            if ($current -ne 1) {
                New-ItemProperty -LiteralPath $entry.PSPath -Name 'IsPromoted' -PropertyType DWord -Value 1 -Force -ErrorAction Stop | Out-Null
                $changed++
            }
        }
        catch {
            # Ignore a tray icon that disappears or cannot be updated.
            Write-Warning ('Could not update tray entry {0}: {1}' -f $entry.PSChildName, $_)
        }
    }
    return $changed
}

function Stop-ExistingWatcher {
    # Only stop our background PowerShell processes, never unrelated PowerShell windows.
    # WMI/CIM is used only at Start/Stop, never by the 30-second watcher.
    $stopped = 0
    try {
        $processes = @(Get-CimInstance -ClassName Win32_Process -Filter "Name='powershell.exe'" -ErrorAction Stop)
        foreach ($process in $processes) {
            if ([int]$process.ProcessId -eq $PID) { continue }
            $cmd = [string]$process.CommandLine
            if (-not $cmd) { continue }
            if ($cmd.IndexOf($dest, [StringComparison]::OrdinalIgnoreCase) -lt 0) { continue }
            if ($cmd -notmatch '(?i)(?:^|\s)-Mode\s+Watch(?:\s|$)') { continue }
            try {
                Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
                $stopped++
            }
            catch {
                Write-Warning ('Could not stop watcher PID {0}: {1}' -f $process.ProcessId, $_)
            }
        }
    }
    catch {
        Write-Warning 'Could not enumerate PowerShell processes; a previous watcher may need up to 30 seconds to exit.'
    }
    return $stopped
}

switch ($Mode) {
    'Once' {
        $count = Set-TrayIconsVisible
        Write-Host "Updated $count tray-icon entries."
    }
    'Install' {
        if (-not $PSCommandPath) { throw 'Run this script from a saved .ps1 file.' }
        if (-not (Test-Path -LiteralPath $exe)) { throw 'Windows PowerShell was not found.' }

        # Removing the autostart entry first tells any previous watcher to exit.
        Remove-ItemProperty -Path $runKey -Name $runName -ErrorAction SilentlyContinue
        Stop-ExistingWatcher | Out-Null

        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        if ([IO.Path]::GetFullPath($PSCommandPath) -ine [IO.Path]::GetFullPath($dest)) {
            Copy-Item -LiteralPath $PSCommandPath -Destination $dest -Force
        }

        $args = '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}" -Mode Watch' -f $dest
        $startupCommand = '"{0}" {1}' -f $exe, $args
        New-ItemProperty -Path $runKey -Name $runName -PropertyType String -Value $startupCommand -Force | Out-Null

        $count = Set-TrayIconsVisible
        Start-Process -FilePath $exe -ArgumentList $args -WindowStyle Hidden -ErrorAction Stop
        Write-Host 'STARTED: tray icons are checked every 30 seconds.' -ForegroundColor Green
        Write-Host 'Starts automatically when you sign in. No administrator privileges required.'
        Write-Host "Existing tray entries updated: $count"
        Write-Host 'To stop and disable autostart, double-click Stop.cmd.'
    }
    'Watch' {
        # Prevent duplicate watchers in the same Windows sign-in session.
        $createdNew = $false
        $mutex = [System.Threading.Mutex]::new($true, 'Local\TrayIconAutoShow_Watcher', [ref]$createdNew)
        if (-not $createdNew) { $mutex.Dispose(); return }
        try {
            while ($true) {
                # Removing the Run entry stops the watcher even if WMI cannot terminate it.
                $installed = Get-ItemProperty -Path $runKey -Name $runName -ErrorAction SilentlyContinue
                if (-not $installed -or -not $installed.$runName) { break }
                Set-TrayIconsVisible | Out-Null
                Start-Sleep -Seconds $intervalSeconds
            }
        }
        finally {
            $mutex.ReleaseMutex()
            $mutex.Dispose()
        }
    }
    'Remove' {
        Remove-ItemProperty -Path $runKey -Name $runName -ErrorAction SilentlyContinue
        $stopped = Stop-ExistingWatcher
        Write-Host 'STOPPED: autostart disabled.' -ForegroundColor Green
        if ($stopped -gt 0) {
            Write-Host "Stopped $stopped background watcher process(es)."
        } else {
            Write-Host 'No active watcher was detected. If one is running, it will exit at its next check (within 30 seconds).'
        }
        Write-Host 'Already visible tray icons stay visible. Start.cmd can enable the feature again.'
    }
}

TRAY ICON AUTO SHOW - WINDOWS 11 (30-SECOND EDITION)
====================================================

WHAT IT DOES
Automatically marks current and new application tray icons as visible on
Windows 11. It checks every 30 seconds and only writes registry values that
are missing or set to hidden.

INSTALL / START
1. Extract the ENTIRE ZIP to a normal folder (e.g. Downloads\TrayIconAutoShow).
2. Double-click Start.cmd. Read the result, then press any key to close it.
3. Done. It installs itself into %LOCALAPPDATA%\TrayIconAutoShow and starts
   quietly in the background every time you sign in.

STOP / DISABLE
Double-click Stop.cmd from the extracted package. It disables the automatic
startup and stops the matching background watcher. If Windows prevents the
process check, the watcher exits at the next check (up to 30 seconds).

WHAT IT CHANGES
- Per-user registry: HKCU\Control Panel\NotifyIconSettings\*\IsPromoted=1
- Per-user startup entry: HKCU\Software\Microsoft\Windows\CurrentVersion\Run\TrayIconAutoShow
- Installed script: %LOCALAPPDATA%\TrayIconAutoShow\TrayIconAutoShow.ps1

NOTES
- No administrator access, installer, network connection or additional
  software required. Uses built-in Windows PowerShell 5.1.
- Does not restart Explorer and does not reset icon choices when stopped.
- If you manually hide an icon while running, it will be shown again on the
  next 30-second check.
- Windows controls which icons exist. Apps must actually create tray icons.
- Some Windows 11 builds may not update an icon immediately after a registry
  change; this is registry polling, not the same mechanism as Windhawk.
- Avoid running a second tray-icon customization utility at the same time.
- Requires the ZIP to be extracted before running either .cmd file.

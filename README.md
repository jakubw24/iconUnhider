# iconUnhider

Keep Windows 11 application notification-area (system tray) icons visible, including icons added by newly installed applications.

**iconUnhider** is a small, per-user PowerShell utility with a simple **double-click Start / Stop** workflow. It checks the Windows notification icon settings every **30 seconds** and enables visibility for icons that are currently marked as hidden.

## Quick start

1. Select **Code → Download ZIP** on the GitHub repository page (or use the separate standalone release package if provided).
2. **Extract the ZIP completely** into a normal folder.
3. Double-click **`Start.cmd`**. Read the confirmation, then press any key to close the window.
4. To disable the watcher, double-click **`Stop.cmd`** from the extracted folder.

`Start.cmd` installs a copy of the watcher into `%LOCALAPPDATA%\TrayIconAutoShow` and registers it to start at your next Windows sign-in. It also runs immediately. You do not need to leave the command window open.

`Stop.cmd` removes the startup registration and stops the watcher. **It does not hide icons again**, delete the installed script, or reset existing tray preferences.

## Features

- Automatically checks existing and newly registered application tray icons every 30 seconds.
- Works per user: **no administrator privileges** required.
- Uses built-in **Windows PowerShell 5.1**; no extra runtimes, services, or external applications.
- Runs quietly in the background after startup.
- Only writes registry values that are absent or not already set to visible.
- Uses process enumeration only during Start / Stop, not on each polling cycle.
- No network access or telemetry in the script.

## How it works

The watcher sets each available `IsPromoted` value to `1` under:

```text
HKEY_CURRENT_USER\Control Panel\NotifyIconSettings\*\IsPromoted
```

It registers its own startup command under:

```text
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
  TrayIconAutoShow
```

The installed script lives at:

```text
%LOCALAPPDATA%\TrayIconAutoShow\TrayIconAutoShow.ps1
```

The older internal script and registry names are intentionally retained to avoid changing the working Start / Stop behaviour while naming the GitHub project **iconUnhider**.

## Manual operation (optional)

From the extracted folder, run a single update without installing the watcher:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\TrayIconAutoShow.ps1 -Mode Once
```

Other supported script modes are `Install`, `Watch`, and `Remove`. The `.cmd` files provide the simplest supported way to install and stop it. The execution policy override applies to the launched PowerShell process; it does not permanently change your system policy.

## Limitations

- **Windows 11** is the intended target. Effectiveness depends on the Windows build and Explorer's handling of notification icon settings.
- Changing the registry might not immediately refresh an icon already displayed by Explorer. This is registry polling, **not** a Windhawk modification or a supported Windows tray-management API.
- Applications still have to create a notification-area icon. This cannot make an icon appear if the application does not provide one.
- Manually hiding an icon while the watcher runs will be overridden on the next check.
- Avoid running another utility that continually changes the same tray icon settings.
- Stopping the watcher does **not** remove `%LOCALAPPDATA%\TrayIconAutoShow`; you may delete that folder manually after using `Stop.cmd` if you want a complete file cleanup.

## Files

| File | Purpose |
| --- | --- |
| `Start.cmd` | Installs and starts the watcher; enables per-user startup. |
| `Stop.cmd` | Stops the watcher and disables startup. |
| `TrayIconAutoShow.ps1` | PowerShell implementation; 30-second polling. |
| `README.txt` | Plain-text quick-start instructions included with the ZIP. |

## Compatibility and testing

The source package was inspected for its registry, process, and startup behaviour. **It has not been executed or verified on a live Windows 11 system in this environment.**

## License

No open-source license has been chosen yet. The repository owner can add one before inviting contributions or reuse.

class UpdateChecker
{
	__New(settings, build)
	{
		this.settings := settings
		this.build := build
debug.start()
debug.write("Current version: " this.build.version)
debug.end()
		
		if (this.settings.checkForUpdates)
		{
			daysSinceLastUpdate := A_Now
			EnvSub, daysSinceLastUpdate, % this.settings.lastUpdateCheck, Days
debug.start()
debug.write("Last update check: " this.settings.lastUpdateCheck)
debug.write("Days: " daysSinceLastUpdate)
debug.end()

			if (daysSinceLastUpdate >= this.settings.checkForUpdates_IntervalDays)
			{
				this.checkForUpdates()
			}
		}
	}
	
	checkForUpdates()
	{
debug.start()
		updateFound := false
		latestRelease := ""
debug.write("Checking for updates")
		
		try
		{
			whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			whr.Open("GET", "https://raw.githubusercontent.com/benallred/SnapX/master/Build.ahk", true)
			whr.Send()
			whr.WaitForResponse(10)
			latestRelease := whr.ResponseText
debug.write("GET succeeded")
		}
		catch
		{
debug.write("GET failed")
		}
		
debug.write("Latest: " latestRelease)
		
		if (InStr(latestRelease, "Build := ", true) == 1)
		{
			RegExMatch(latestRelease, "O)version\s*:\s*""(.+?)""", match)
			newVersion := match.Value(1)
debug.write("Old version: " this.build.version)
debug.write("New version: " newVersion)

			if (newVersion != this.build.version)
			{
				updateFound := true
				MsgBox, 0x44, % this.settings.programTitle " Update Available", % this.settings.programTitle " version " newVersion " is available.`n`nWould you like to open the download page now?" ; 0x4 = Yes/No; 0x40 = Info
				IfMsgBox Yes
				{
					Run, https://github.com/benallred/SnapX/releases/latest
				}
			}
		}
		
		this.settings.lastUpdateCheck := A_Now
debug.end()
		
		return updateFound
	}
}
class Settings
{
	static programTitle := "SnapX"
	static programDescription := "Replacement for Windows/Aero Snap"
	
	__New()
	{
		this.iniFile := this.programTitle ".ini"
		
		IfNotExist % this.iniFile
		{
			FileAppend, % ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;`n", % this.iniFile
			FileAppend, % ";; Make sure to reload " this.programTitle " after making changes (right-click tray menu > Reload).`n", % this.iniFile
			FileAppend, % ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;`n", % this.iniFile
		}
		
		this.ReadSetting("debug", "Settings", 0)
		this.ReadSetting("horizontalSections", "Settings", 0)
		if (!this.horizontalSections || this.horizontalSections < 2)
		{
			SetTimer, ChangeButtonNames_HorizontalSections, 50
			MsgBox, 4, % this.programTitle " Settings", % "This is your first time running " this.programTitle ", by Ben Allred.`n`nPlease select your desired horizontal grid size.`n`nThis setting can be changed via the " this.iniFile " file.`n(Access this via the icon in the system tray.)"
			IfMsgBox, Yes
				this.horizontalSections := 4
			else ; No
				this.horizontalSections := 3

			this.WriteSetting("horizontalSections", "Settings")
		}
		
		this.ReadSetting("verticalSections", "Settings", 0)
		if (!this.verticalSections || this.verticalSections < 1)
		{
			this.verticalSections := 1
		}

		this.ReadSetting("runOnStartup", "Settings", -1)
		if (this.runOnStartup < 0)
		{
			this.runOnStartup := 1
			this.WriteSetting("runOnStartup", "Settings")
		}

		this.startupLinkFile := A_Startup "\" this.programTitle ".lnk"
		if (this.runOnStartup > 0)
		{
			IfNotExist, % this.startupLinkFile
			{
				FileCreateShortcut, % A_ScriptFullPath, % this.startupLinkFile, % A_ScriptDir, , % this.programDescription, % A_IsCompiled ? A_ScriptFullPath : StrReplace(A_ScriptFullPath, ".ahk", ".ico")
			}
		}
		else ; if (runOnStartup == 0)
		{
			FileDelete, % this.startupLinkFile
		}

		this.ReadSetting("checkForUpdates", "Updates", -1)
		if (this.checkForUpdates < 0)
		{
			this.checkForUpdates := 1
			this.WriteSetting("checkForUpdates", "Updates")
		}

		this.ReadSetting("checkForUpdates_IntervalDays", "Updates", -1)
		if (this.checkForUpdates_IntervalDays < 0)
		{
			this.checkForUpdates_IntervalDays := 7
			this.WriteSetting("checkForUpdates_IntervalDays", "Updates")
		}
		
		this.ReadSetting("lastUpdateCheck", "Updates", 1900)
	}
	
	ReadSetting(varName, section, default)
	{
		IniRead, tmp, % this.iniFile, % section, % varName, % default
		this[varName] := tmp
	}
	
	WriteSetting(varName, section)
	{
		IniWrite, % this[varName], % this.iniFile, % section, % varName
	}
}

ChangeButtonNames_HorizontalSections()
{
	IfWinNotExist, % Settings.programTitle " Settings"
		return
	SetTimer, ChangeButtonNames_HorizontalSections, Off
	WinActivate
	ControlSetText, Button1, &4
	ControlSetText, Button2, &3
}
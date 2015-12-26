class Settings
{
	;@Ahk2Exe-SetName SnapX
	static programTitle := "SnapX"
	;@Ahk2Exe-SetDescription Replacement for Windows/Aero Snap
	static programDescription := "Replacement for Windows/Aero Snap"
	
	_debug := 0
	debug[]
	{
		get
		{
			return this._debug
		}
		set
		{
			this._debug := value
			return this._debug
		}
	}
	
	_horizontalSections := -1
	horizontalSections[fromIniFile = false]
	{
		get
		{
			return this._horizontalSections
		}
		set
		{
			if (value != this._horizontalSections)
			{
				this._horizontalSections := value
				if (!fromIniFile)
				{
					this.writeSetting("horizontalSections", "Settings")
				}
			}
			return this._horizontalSections
		}
	}
	
	_verticalSections := -1
	verticalSections[fromIniFile = false]
	{
		get
		{
			return this._verticalSections
		}
		set
		{
			if (value != this._verticalSections)
			{
				this._verticalSections := value
				if (!fromIniFile)
				{
					this.writeSetting("verticalSections", "Settings")
				}
			}
			return this._verticalSections
		}
	}
	
	_runOnStartup := -1
	runOnStartup[fromIniFile = false]
	{
		get
		{
			return this._runOnStartup
		}
		set
		{
			if (value != this._runOnStartup)
			{
				this._runOnStartup := value
				if (!fromIniFile)
				{
					this.writeSetting("runOnStartup", "Settings")
				}

				this.startupLinkFile := A_Startup "\" this.programTitle ".lnk"
				if (this._runOnStartup > 0)
				{
					IfNotExist, % this.startupLinkFile
					{
						FileCreateShortcut, % A_ScriptFullPath, % this.startupLinkFile, % A_ScriptDir, , % this.programDescription, % A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\Resources\" StrReplace(A_ScriptName, ".ahk", ".ico")
					}
				}
				else ; if (this._runOnStartup == 0)
				{
					FileDelete, % this.startupLinkFile
				}
			}
			return this._runOnStartup
		}
	}
	
	_checkForUpdates := -1
	checkForUpdates[fromIniFile = false]
	{
		get
		{
			return this._checkForUpdates
		}
		set
		{
			if (value != this._checkForUpdates)
			{
				this._checkForUpdates := value
				if (!fromIniFile)
				{
					this.writeSetting("checkForUpdates", "Updates")
				}
			}
			return this._checkForUpdates
		}
	}
	
	_checkForUpdates_IntervalDays := -1
	checkForUpdates_IntervalDays[fromIniFile = false]
	{
		get
		{
			return this._checkForUpdates_IntervalDays
		}
		set
		{
			if (value != this._checkForUpdates_IntervalDays)
			{
				this._checkForUpdates_IntervalDays := value
				if (!fromIniFile)
				{
					this.writeSetting("checkForUpdates_IntervalDays", "Updates")
				}
			}
			return this._checkForUpdates_IntervalDays
		}
	}
	
	_lastUpdateCheck := 1900
	lastUpdateCheck[fromIniFile = false]
	{
		get
		{
			return this._lastUpdateCheck
		}
		set
		{
			if (value != this._lastUpdateCheck)
			{
				this._lastUpdateCheck := value
				if (!fromIniFile)
				{
					this.writeSetting("lastUpdateCheck", "Updates")
				}
			}
			return this._lastUpdateCheck
		}
	}
	
	__New()
	{
		this.iniFile := this.programTitle ".ini"
		firstRun := false
		
		IfNotExist % this.iniFile
		{
			firstRun := true
			
			FileAppend, % ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;`n", % this.iniFile
			FileAppend, % ";; Make sure to reload " this.programTitle " after editing this file directly (right-click tray menu > Reload).`n", % this.iniFile
			FileAppend, % ";; Alternatively, use the SnapX Settings GUI to make changes (right-click tray menu > Settings).`n", % this.iniFile
			FileAppend, % ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;`n", % this.iniFile
		}
		
		this.readSetting("debug", "Settings", this._debug)
		
		this.readSetting("horizontalSections", "Settings", this._horizontalSections)
		if (this.horizontalSections < 2)
		{
			this.horizontalSections := 4
		}
		
		this.readSetting("verticalSections", "Settings", this._verticalSections)
		if (this.verticalSections < 1)
		{
			this.verticalSections := 2
		}

		this.readSetting("runOnStartup", "Settings", this._runOnStartup)
		if (this.runOnStartup < 0)
		{
			this.runOnStartup := 1
		}

		this.readSetting("checkForUpdates", "Updates", this._checkForUpdates)
		if (this.checkForUpdates < 0)
		{
			this.checkForUpdates := 1
		}

		this.readSetting("checkForUpdates_IntervalDays", "Updates", this._checkForUpdates_IntervalDays)
		if (this.checkForUpdates_IntervalDays < 0)
		{
			this.checkForUpdates_IntervalDays := 7
		}
		
		this.readSetting("lastUpdateCheck", "Updates", this._lastUpdateCheck)
		
		if (firstRun)
		{
			MsgBox, , % "Thank you for using " this.programTitle, % "This is your first time running " this.programTitle ", by Ben Allred.`n`nYou are running with the recommended default settings.`nYou can change your settings via the Settings option in the tray menu."
		}
	}
	
	readSetting(varName, section, default)
	{
		IniRead, tmp, % this.iniFile, % section, % varName, % default
		this[varName](true) := tmp
	}
	
	writeSetting(varName, section)
	{
		IniWrite, % this[varName], % this.iniFile, % section, % varName
	}
}
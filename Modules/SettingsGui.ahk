global SettingsGui_HorizontalSections
global SettingsGui_VerticalSections
global SettingsGui_RunOnStartup
global SettingsGui_CheckForUpdates

class SettingsGui
{
	__New(settings)
	{
		this.settings := settings
		
		Gui, Settings:New, -MaximizeBox
		
		Gui, Font, s18 bold
		Gui, Add, Text, , % this.settings.programTitle " Settings"
		
		Gui, Margin, , 10
		Gui, Font
		Gui, Font, s10
		
		Gui, Add, Edit, Number Right w40 Section
		Gui, Add, UpDown, vSettingsGui_HorizontalSections Range2-20, % this.settings.horizontalSections
		Gui, Add, Text, x+4 yp+3, % "Horizontal grid size"
		
		Gui, Add, Edit, Number Right w40 xs
		Gui, Add, UpDown, vSettingsGui_VerticalSections Range1-20, % this.settings.verticalSections
		Gui, Add, Text, x+4 yp+3, % "Vertical grid size"
		
		Gui, Add, Checkbox, % "vSettingsGui_RunOnStartup xs" (this.settings.runOnStartup ? " Checked" : ""), % "Start " this.settings.programTitle " on system startup"
		Gui, Add, Checkbox, % "vSettingsGui_CheckForUpdates" (this.settings.checkForUpdates ? " Checked" : ""), % "Check for updates"
		
		Gui, Font
		openIniFileMethod := ObjBindMethod(this, "openIniFile")
		static IniFileLink
		Gui, Add, Link, vIniFileLink, % "<a>Open " this.settings.iniFile "</a>"
		GuiControl, +g, IniFileLink, % openIniFileMethod
		
		Gui, Font, s10
		onSubmitMethod := ObjBindMethod(this, "onSubmit")
		static OKButton
		Gui, Add, Button, vOKButton Default w80, OK
		GuiControl, +g, OKButton, % onSubmitMethod
		static CancelButton
		Gui, Add, Button, vCancelButton gSettingsGuiEscape x+m wp, Cancel
		
		Gui, Margin, , 18
		Gui, Show, Hide, % this.settings.programTitle " Settings"
		
		; Get GUI client width
		Gui, +LastFound
		WinGet, activeWindowHandle, ID
		GetClientRect(activeWindowHandle, cr)
		
		; Center ini file link
		GuiControlGet, IniFileLink, Pos
		GuiControl, Move, IniFileLink, % "x" ((cr.right - IniFileLinkW) / 2)
		
		; Center OK and Cancel buttons
		buttonRowPadding := (cr.right - (80 + 80 + 10)) / 2 ; OKButton width + CancelButton width + margin (padding in between buttons)
		GuiControl, Move, OKButton, % "x" buttonRowPadding
		GuiControl, Move, CancelButton, % "x" (cr.right - buttonRowPadding - 80)
		
		Gui, Show
		GuiControl, Focus, OKButton
	}
	
	openIniFile(ctrlHwnd, guiEvent, eventInfo, errorLvl)
	{
		Run, % "notepad.exe " this.settings.iniFile
		SettingsGuiEscape(ctrlHwnd)
	}
	
	onSubmit()
	{
		GuiControlGet, horizontalSections, Settings:, SettingsGui_HorizontalSections
		GuiControlGet, verticalSections, Settings:, SettingsGui_VerticalSections
		GuiControlGet, runOnStartup, Settings:, SettingsGui_RunOnStartup
		GuiControlGet, checkForUpdates, Settings:, SettingsGui_CheckForUpdates
		
		this.settings.horizontalSections := horizontalSections
		this.settings.verticalSections := verticalSections
		this.settings.runOnStartup       := runOnStartup
		this.settings.checkForUpdates    := checkForUpdates
		
		Gui, Settings:Destroy
	}
}

SettingsGuiEscape(hwnd)
{
	Gui, Settings:Destroy
}
class AboutGui
{
	__New(settings, build)
	{
		this.settings := settings
		this.build := build
		
		Gui, About:New, -MaximizeBox
		
		Gui, About:Font, s24 bold
		Gui, About:Add, Text, , % this.settings.programTitle
		
		Gui, About:Margin, , 0
		Gui, About:Font
		Gui, About:Add, Text, , % (this.build.version ? "v" this.build.version : "AutoHotkey script")
										. ", " (A_PtrSize * 8) "-bit"
										. (this.settings.debug ? ", Debug enabled" : "")
										. (A_IsCompiled ? "" : ", not compiled")
										. (A_IsAdmin ? "" : ", not running as administrator") ; shouldn't ever display
		
		Gui, About:Add, Text, , Copyright (c) Ben Allred
		
		Gui, About:Margin, , 10
		Gui, About:Font, s12
		Gui, About:Add, Text, , % this.settings.programDescription
		Gui, About:Add, Link, , Website: <a href="https://github.com/benallred/SnapX">https://github.com/benallred/SnapX</a>
		
		Gui, About:Margin, , 18
		Gui, About:Show, , % this.settings.programTitle
	}
}

AboutGuiEscape(hwnd)
{
	Gui, About:Destroy
}
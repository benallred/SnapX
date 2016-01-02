class HelpGui
{
	__New(settings)
	{
		this.settings := settings
		
		ic := A_IsCompiled
		
		Gui, Help:New, -MaximizeBox
		
		Gui, Font, s24 bold
		Gui, Add, Text, , % this.settings.programTitle " Keys"
		
		Gui, Font
		Gui, Font, s12
		Gui, Margin, , 10
		
		Gui, Add, Text, , Horizontal Snapping
		
		Gui, Add, Picture, % "Section w16 h-1" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"
		Gui, Add, Text, x+4 yp-2, + Left
		
		Gui, Font, s8
		Gui, Add, Text, x+8 yp+3, (or
		Gui, Add, Picture, % "w10 h-1 x+4 yp+2" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + Alt + Left)
		
		Gui, Font, s12
		Gui, Add, Picture, % "w16 h-1 xs" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + Right
		
		Gui, Font, s8
		Gui, Add, Text, x+8 yp+3, (or
		Gui, Add, Picture, % "w10 h-1 x+4 yp+2" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + Alt + Right)
		
		Gui, Font, s12
		Gui, Add, Picture, % "w16 h-1 xs" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + Up
		
		Gui, Add, Picture, % "w16 h-1 xs" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + Down
		
		Gui, Margin, , 18
		Gui, Add, Text, xs, Vertical Snapping
		Gui, Margin, , 10
		
		Gui, Add, Picture, % "w16 h-1 xs" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + PgUp
		
		Gui, Add, Picture, % "w16 h-1 xs" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + PgDn
		
		Gui, Add, Picture, % "w16 h-1 xs" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + Alt + Up
		
		Gui, Add, Picture, % "w16 h-1 xs" (ic ? " Icon14" : ""), % ic ? A_ScriptName : "Resources\Windows.ico"		
		Gui, Add, Text, x+4 yp-2, + Alt + Down
		
		Gui, Margin, , 0
		Gui, Add, Text, ys-2, Move left
		Gui, Add, Text, , Move right
		Gui, Add, Text, , Increase snap width
		Gui, Add, Text, , Decrease snap width
		
		Gui, Margin, , 10
		Gui, Add, Text, ,
		
		Gui, Margin, , 0
		Gui, Add, Text, , Adjust height up
		Gui, Add, Text, , Adjust height down
		Gui, Add, Text, , Move up
		Gui, Add, Text, , Move down
		
		Gui, Margin, , 18
		Gui, Show, , % this.settings.programTitle " Keys"
	}
	
}

HelpGuiEscape(hwnd)
{
	Gui, Help:Destroy
}
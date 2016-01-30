global DebugInfo

class Debug
{
	__New(settings)
	{
		this.settings := settings
		
		onExit := ObjBindMethod(this, "onExit")
		OnExit(onExit)
		
		this.init()
	}
	
	init()
	{
		this.createDebugWindow()
		
		FileDelete, % this.settings.logFile
	}
	
	createDebugWindow()
	{
		if (this.settings.debug > 1)
		{
			Gui, +AlwaysOnTop
			Gui, Add, ListView, vDebugInfo r20 w500 -Hdr, DebugId|Debug Info
			Gui, Show, x10 y10, % this.settings.programTitle " Debug Info"
;			Gui, +LastFound
;			WinSet, Transparent, % 255 * 0.8
		}
	}
	
	start()
	{
		if (this.settings.debug)
		{
			if (!this.file)
			{
				this.file := FileOpen(this.settings.logFile, "a`n")
				FormatTime, now, A_Now, yyyy-MM-dd HH:mm:ss.'%A_MSec%'
				this.file.Write(now)
				
				if (this.settings.debug > 1)
				{
					this.lastRow := LV_Add("")
					LV_Modify(this.lastRow, "Vis", this.lastRow)
					LV_ModifyCol(1, "Auto")
				}
			}
		}
	}
	
	end()
	{
		if (this.settings.debug && this.file)
		{
			this.file.WriteLine()
			this.file.Close()
			this.file := 0
		}
	}
	
	write(items*)
	{
		if (this.settings.debug)
		{
			text := Join(" ", items*)
			
			if (!this.file)
			{
				this.start()
				text := "CALL start(); " text
			}
			
			this.file.Write("; " text)
			
			if (this.settings.debug > 1)
			{
				LV_GetText(prepend, this.lastRow, 2)
				LV_Modify(this.lastRow, "Col2", (prepend ? prepend "; " : "") text)
				LV_ModifyCol(2, "Auto")
			}
		}
	}

	writeArray(array, itemProperty)
	{
		if (this.settings.debug)
		{
			s := ""
			for i, item in array
			{
				if (s <> "")
				{
					s := s ", "
				}
				
				s := s item[itemProperty]
			}
			this.write(s)
		}
	}
	
	onExit(exitReason, exitCode)
	{
		this.end()
	}
}
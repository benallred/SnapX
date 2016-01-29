global DebugInfo

class Debug
{
	__New(settings)
	{
		this.settings := settings
		this.createDebugWindow()
	}
	
	createDebugWindow()
	{
		if (this.settings.debug)
		{
			Gui, +AlwaysOnTop
			Gui, Add, ListView, vDebugInfo r20 w300 -Hdr, DebugId|Debug Info
			Gui, Show, x10 y10, % this.settings.programTitle " Debug Info"
		}
	}

	write(items*)
	{
		if (this.settings.debug)
		{
			lastRow := LV_Add("", , Join(" ", items*))
			LV_Modify(lastRow, "Vis", lastRow)
			LV_ModifyCol(1, "Auto")
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
}
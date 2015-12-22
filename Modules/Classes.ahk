class Operation
{
	static None            := 0
	static Minimized       := 1
	static Restored        := 2
	static Snapped         := 3
	static Moved           := 4
	static RestoredSnapped := 5
	static Maximized       := 6
}

class SizePosition
{
	__New(x, y, w=0, h=0, r=0, b=0, xo=0, yo=0)
	{
		this.x := x
		this.l := x
		this.y := y
		this.t := y
		this.w := w ? w : r ? r - x : 0
		this.h := h ? h : b ? b - y : 0
		this.r := r ? r : w ? x + w : 0
		this.b := b ? b : h ? y + h : 0
		this.cx := x && w ? x + w / 2 : 0
		this.cy := y && h ? y + h / 2 : 0
		this.xo := xo
		this.yo := yo
	}
}

class SnapMonitor
{
	__New(monitorId)
	{
		this.id := monitorId
		
		SysGet, monArea, Monitor, % monitorId
		this.area := new SizePosition(monAreaLeft, monAreaTop, , , monAreaRight, monAreaBottom)
		
		SysGet, monWorkArea, MonitorWorkArea, % monitorId
		this.workarea := new SizePosition(monWorkAreaLeft, monWorkAreaTop, , , monWorkAreaRight, monWorkAreaBottom, monWorkAreaLeft - monAreaLeft, monWorkAreaTop - monAreaTop)
	}
}

class SnapWindow
{
	__New(hwnd)
	{
		this.handle := hwnd
		
		this.position := new SizePosition(0, 0)
		this.snapped := 0
		this.grid := { left:0, top:0, width:0, height:0 }
		this.restoredpos := { left:0.0, top:0.0, width:0.0, height:0.0 } ; in percentage of monitor
	}
	
	UpdatePosition()
	{
		WinGetPos, winX, winY, winW, winH, % "ahk_id " this.handle
		WinGetPosEx(this.handle, , , , , xOffset, yOffset)
		this.position := new SizePosition(winX, winY, winW, winH, , , xOffset, yOffset)
	}
}

class SizeOf
{
	static UInt         := 32 // 8
	static Int          := 32 // 8
	static Long         := SizeOf.Int
	static Point        := SizeOf.Long * 2
	static Rect         := SizeOf.Long * 4
	static Short        := 16 // 8
	static Variant_Bool := SizeOf.Short
}

class WINDOWPLACEMENT
{
	; UINT, UINT, UINT, POINT, POINT, RECT
	__New(length, flags, showCmd, ptMinPosition, ptMaxPosition, rcNormalPosition)
	{
		this.length := length
		this.flags := flags
		this.showCmd := showCmd
		this.ptMinPosition := ptMinPosition
		this.ptMaxPosition := ptMaxPosition
		this.rcNormalPosition := rcNormalPosition
	}
}

class tagPOINT
{
	; LONG, LONG
	__New(x, y)
	{
		this.x := x
		this.y := y
	}
}

class _RECT
{
	; LONG, LONG, LONG, LONG
	__New(left, top, right, bottom)
	{
		this.left := left
		this.top := top
		this.right := right
		this.bottom := bottom
	}
}
GetMonitorId(hwnd)
{
	local mon, winCenterX, winCenterY
	
	GetWindowPlacement(hwnd, wp) ; GetWindowPlacement returns restored position of window (need this in case hwnd is minimized)
	
	SysGet, monitorCount, MonitorCount
	
	Loop, % monitorCount
	{
		mon := new SnapMonitor(A_Index)
		
		winCenterX := (wp.rcNormalPosition.left + mon.workarea.xo + wp.rcNormalPosition.right + mon.workarea.xo) / 2 ; wp coordinates are in workspace coordinates
		winCenterY := (wp.rcNormalPosition.top + mon.workarea.yo + wp.rcNormalPosition.bottom + mon.workarea.yo) / 2 ; wp coordinates are in workspace coordinates
		if (winCenterX >= mon.area.x && winCenterX <= mon.area.r && winCenterY >= mon.area.y && winCenterY <= mon.area.b)
		{
			return % A_Index
		}
	}
	
	return 1
}

NumGetInc(ByRef VarOrAddress, ByRef Offset, Type)
{
	value := NumGet(VarOrAddress, Offset, Type)
	Offset := Offset + SizeOf[Type]
	return value
}

NumPutInc(Number, ByRef VarOrAddress, ByRef Offset, Type)
{
	NumPut(Number, VarOrAddress, Offset, Type)
	Offset := Offset + SizeOf[Type]
}

GetWindowPlacement(hwnd, ByRef lpwndpl)
{
	VarSetCapacity(_lpwndpl, 44)
	NumPut(44, _lpwndpl)
	result := DllCall("GetWindowPlacement", Ptr, hwnd, Ptr, &_lpwndpl)
	runningOffset := 0
	lpwndpl := new WINDOWPLACEMENT(NumGetInc(_lpwndpl, runningOffset, "UInt")
											, NumGetInc(_lpwndpl, runningOffset, "UInt")
											, NumGetInc(_lpwndpl, runningOffset, "UInt")
											, new tagPOINT(NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int"))
											, new tagPOINT(NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int"))
											, new _RECT(NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int")))
	return result
}

SetWindowPlacement(hwnd, ByRef lpwndpl)
{
	VarSetCapacity(_lpwndpl, 44)
	runningOffset := 0
	NumPutInc(lpwndpl.length , _lpwndpl, runningOffset, "UInt")
	NumPutInc(lpwndpl.flags  , _lpwndpl, runningOffset, "UInt")
	NumPutInc(lpwndpl.showCmd, _lpwndpl, runningOffset, "UInt")
	NumPutInc(lpwndpl.ptMinPosition.x, _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.ptMinPosition.y, _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.ptMaxPosition.x, _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.ptMaxPosition.y, _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.rcNormalPosition.left  , _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.rcNormalPosition.top   , _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.rcNormalPosition.right , _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.rcNormalPosition.bottom, _lpwndpl, runningOffset, "Int")
	result := DllCall("SetWindowPlacement", Ptr, hwnd, Ptr, &_lpwndpl)
	return result
}

IndexOf(array, value, itemProperty = "")
{
	local i, item
	for i, item in array
	{
		if ((itemProperty <> "" && item[itemProperty] = value) || item = value)
		{
			return i
		}
	}
	return 0
}
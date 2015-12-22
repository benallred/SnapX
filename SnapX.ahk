#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include Include\WinGetPosEx.ahk
#Include Include\Const_WinUser.ahk

#Include Modules\Settings.ahk
#Include Modules\Debug.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants

Build := { version: "" }
#Include *i Build.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Startup

Menu, Tray, Icon, shell32.dll, 160 ; other options: 16, 253, 255, 306
Menu, Tray, NoStandard

if not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}

SoundPlay *64
TrayTip, % Settings.programTitle, Loaded

Settings := new Settings()
Debug := new Debug(Settings)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check for Updates

if (Settings.checkForUpdates)
{
	daysSinceLastUpdate := A_Now
	EnvSub, daysSinceLastUpdate, % Settings.lastUpdateCheck, Days
Debug.write("Last update check: " Settings.lastUpdateCheck "; (days:) " daysSinceLastUpdate)

	if (daysSinceLastUpdate >= Settings.checkForUpdates_IntervalDays)
	{
		CheckForUpdates()
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tray Menu

Menu, Tray, Add, % Settings.programTitle, Tray_About
Menu, Tray, Icon, % Settings.programTitle, shell32.dll, 160
Menu, Tray, Add, &About, Tray_About
Menu, Tray, Icon, &About, shell32.dll, 222 ; other options: 155, 176, 211, 222, 225, 278
Menu, Tray, Add, Chec&k for update, Tray_Update
Menu, Tray, Icon, Chec&k for update, shell32.dll, 47 ; other options: 47, 123
Menu, Tray, Add
Menu, Tray, Add, &Settings, Tray_Settings
Menu, Tray, Icon, &Settings, shell32.dll, 316
Menu, Tray, Add, &Reload, Tray_Reload
Menu, Tray, Icon, &Reload, shell32.dll, 239
Menu, Tray, Add, S&uspend, Tray_Suspend
Menu, Tray, Icon, S&uspend, shell32.dll, 145 ; other options: 238, 220
Menu, Tray, Add, E&xit, Tray_Exit
Menu, Tray, Icon, E&xit, shell32.dll, 132
Menu, Tray, Default, % Settings.programTitle
Menu, Tray, Tip, % Settings.programTitle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup

TrackedWindows := []
LastOperation := Operation.None
LastWindowHandle := -1
StillHoldingWinKey := 0

OnExit("ExitFunc")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hotkeys

#If Settings.debug
#`::Reload ; for ease of testing during development
#If

#Left::MoveWindow(-1, 0)

#Right::MoveWindow(1, 0)

#Up::MoveWindow(0, 1)

#Down::MoveWindow(0, -1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Functionality

MoveWindow(horizontalDirection, horizontalSize)
{
	global TrackedWindows, LastOperation, LastWindowHandle, StillHoldingWinKey
	
	; state: minimized and LWin not released yet
	if (LastOperation == Operation.Minimized && StillHoldingWinKey)
	{
Debug.write("state: minimized")
		; action: win+up
		if (horizontalSize > 0)
		{
Debug.write("   action: restore")
			StillHoldingWinKey := 0
			LastOperation := Operation.Restored
			WinRestore, % "ahk_id " LastWindowHandle  ; WinRestore followed by WinActivate, with ahk_id specified explicitely on each, was the only way I could get
			WinActivate, % "ahk_id " LastWindowHandle ; Win+Down, Win+Up (particularly when done in quick succession) to restore and set focus again reliably.
		}
		; action: anything else
		return
	}
	
	WinGet, activeWindowHandle, ID, A
	
	WinGet, activeWindowStyle, Style, A
	
	; state: not resizable
	if (!(activeWindowStyle & WS.SIZEBOX)) ; if window is not resizable
	{
		; state: minimizable
		if (activeWindowStyle & WS.MINIMIZEBOX) ; if window is minimizable
		{
			; action: win+down
			if (horizontalSize < 0)
			{
Debug.write("state: restored")
Debug.write("   action: minimize")
				LastWindowHandle := activeWindowHandle
				MinimizeAndKeyWaitLWin()
			}
			; action: anything else
			; (continue)
		}
		return
	}

	index := IndexOf(TrackedWindows, activeWindowHandle, "handle")
	if index < 1
	{
		window := new SnapWindow(activeWindowHandle)
		index := TrackedWindows.Push(window)
	}
	
	window := TrackedWindows[index]
	LastWindowHandle := window.handle
	
	monitorId := GetMonitorId(window.handle)
	mon := new SnapMonitor(monitorId)
	
	WinGet, minMaxState, MinMax, A
	widthFactor  := mon.workarea.w / Settings.horizontalSections
	heightFactor := mon.workarea.h / Settings.verticalSections
	
	; state: minimized
	if (minMaxState < 0)
	{
Debug.write("state: minimized")
		; action: win+up
		if (horizontalSize > 0)
		{
Debug.write("   action: restore")
			LastOperation := Operation.Restored
			WinRestore, A
		}
		; action: anything else
		return
	}
	
	; state: maximized
	else if (minMaxState > 0)
	{
Debug.write("state: maximized")
		; action: win+down
		if (horizontalSize < 0)
		{
Debug.write("   action: restore snapped")
			LastOperation := Operation.RestoredSnapped
			WinRestore, A
		}
		; action: anything else
		return
	}
	
	; state: snapped
	else if (window.snapped == 1)
	{
Debug.write("state: snapped")
		; state: width == max - 1
		if (window.grid.width >= Settings.horizontalSections - 1)
		{
			; action: win+up
			if (horizontalSize > 0)
			{
Debug.write("   action: maximize")
				LastOperation := Operation.Maximized
				WinMaximize, A
				return
			}
			; action: anything else
			; (continue)
		}
		
		; state: width == 1
		if (window.grid.width == 1)
		{
			; action: win+down
			if (horizontalSize < 0)
			{
Debug.write("   action: restore unsnapped")
				window.snapped := 0
				WinMove, A, , window.restoredpos.left   * mon.workarea.w + mon.workarea.x
								, window.restoredpos.top    * mon.workarea.h + mon.workarea.y
								, window.restoredpos.width  * mon.workarea.w
								, window.restoredpos.height * mon.workarea.h ; "restore" from snapped state
				return
			}
			; action: anything else
			; (continue)
		}
		
		; action: all
Debug.write("   action: " (horizontalDirection ? "move" : horizontalSize ? "resize" : "what?"))
		LastOperation := Operation.Moved
		window.grid.left := window.grid.left + horizontalDirection
		window.grid.left := window.grid.left + (horizontalSize < 0 && window.grid.left + window.grid.width >= Settings.horizontalSections ? 1 : 0) ; keep right edge attached to monitor edge if shrinking
		window.grid.top := 0
		window.grid.width := window.grid.width + horizontalSize
		window.grid.height := 1
	}
	
	; state: restored
	else if (window.snapped == 0)
	{
Debug.write("state: restored")
		; action: win+down
		if (horizontalSize < 0)
		{
			; state: minimizable
			if (activeWindowStyle & WS.MINIMIZEBOX) ; if window is minimizable
			{
Debug.write("   action: minimize")
				MinimizeAndKeyWaitLWin()
			}
			return
		}
		
		window.UpdatePosition()
		
		; action: anything else
Debug.write("   action: snap")
		LastOperation := Operation.Snapped
		window.snapped := 1
; Snap based on left/right edges and left/right direction pushed
		window.grid.left := Floor(((horizontalDirection < 0 ? window.position.x : horizontalDirection > 0 ? window.position.r : window.position.cx) - mon.workarea.x) / mon.workarea.w * Settings.horizontalSections)
; Original - Snap based on center coordinates
;		window.grid.left := Floor((window.position.cx - mon.workarea.x) / mon.workarea.w * Settings.horizontalSections)
; Always snaps to current centercoords position, regardless of snap direction pushed
;		(do nothing more)
; Does not snap to current centercoords position - always left or right of current centercoords (unless against edge, of course)
;		window.grid.left := window.grid.left + horizontalDirection
; Shift one more snap direction if starting snap position is on opposite side of the screen from indicated direction
;		window.grid.left := window.grid.left
;									+ ((Settings.horizontalSections - 1) / 2 - window.grid.left > 0 == horizontalDirection > 0 ; if snap position is on the opposite side of the screen as horizontal direction pushed (snap is 0 or 1 and win+right pushed; or snap is 2 or 3 and win+left pushed)
;										|| (Settings.horizontalSections - 1) / 2 - window.grid.left == 0 ; or if snap position is exact center (forward-compatibility for allowing horizontalSections == 3 (or any odd number))
;										 ? horizontalDirection ; shift one more snap indicated direction
;										 : 0)
; Always snap against edge in direction pushed
;		window.grid.left := horizontalDirection < 0 ? 0 : horizontalDirection > 0 ? Settings.horizontalSections - 1 : window.grid.left
; Always snap against center edge in direction pushed
;		window.grid.left := horizontalDirection < 0 ? Settings.horizontalSections // 2 - 1 : horizontalDirection > 0 ? (Settings.horizontalSections + 1) // 2 : window.grid.left
		window.grid.top := 0
		window.grid.width := 1 + horizontalSize
		window.grid.height := 1
		window.restoredpos.left   := (window.position.x - mon.workarea.x) / mon.workarea.w
		window.restoredpos.top    := (window.position.y - mon.workarea.y) / mon.workarea.h
		window.restoredpos.width  :=  window.position.w                   / mon.workarea.w
		window.restoredpos.height :=  window.position.h                   / mon.workarea.h
	}
	
	; Enforce snap boundaries
	
	if window.grid.left + window.grid.width > Settings.horizontalSections
	{
		window.grid.left := window.grid.left - 1
	}
	
	if window.grid.left < 0
	{
		window.grid.left := 0
	}
	
	; Move/resize snap
	WinMove, A, , window.grid.left   * widthFactor  +    window.position.xo + mon.workarea.x
					, window.grid.top    * heightFactor                         + mon.workarea.y
					, window.grid.width  * widthFactor  + -2*window.position.xo
					, window.grid.height * heightFactor + -1*window.position.xo ; + -2*window.position.yo + 1
}

MinimizeAndKeyWaitLWin()
{
	global LastOperation, StillHoldingWinKey
	StillHoldingWinKey := 1
	LastOperation := Operation.Minimized
	WinMinimize, A
	While StillHoldingWinKey
	{
		KeyWait, LWin, T0.25
		if (!ErrorLevel)
		{
			StillHoldingWinKey := 0
		}
	}
}

ExitFunc(exitReason, exitCode)
{
	local i, window
	local monitorId, mon
	local minMaxState
	
	TrayTip, % Settings.programTitle, Resetting snapped windows to their pre-snap size and position
	
	for i, window in TrackedWindows
	{
		; state: snapped
		if (window.snapped == 1)
		{
			monitorId := GetMonitorId(window.handle)
			mon := new SnapMonitor(monitorId)
			
			WinGet, minMaxState, MinMax, % "ahk_id " window.handle
			
			; state: minimized or maximized
			if (minMaxState != 0)
			{
				GetWindowPlacement(window.handle, wp)
				wp.rcNormalPosition.left   :=                            window.restoredpos.left   * mon.workarea.w + mon.area.x
				wp.rcNormalPosition.top    :=                            window.restoredpos.top    * mon.workarea.h + mon.area.y
				wp.rcNormalPosition.right  := wp.rcNormalPosition.left + window.restoredpos.width  * mon.workarea.w
				wp.rcNormalPosition.bottom := wp.rcNormalPosition.top  + window.restoredpos.height * mon.workarea.h
				SetWindowPlacement(window.handle, wp) ; set restored position to pre-snap state (maintains current minimized or maximized status)
			}
			else
			{
				WinMove, % "ahk_id " window.handle, , window.restoredpos.left   * mon.workarea.w + mon.workarea.x
																, window.restoredpos.top    * mon.workarea.h + mon.workarea.y
																, window.restoredpos.width  * mon.workarea.w
																, window.restoredpos.height * mon.workarea.h ; "restore" from snapped state
			}
		}
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Settings and Tray

Tray_Noop(itemName, itemPos, menuName)
{
}

Tray_About(itemName, itemPos, menuName)
{
	Global Build
	
	Gui, About:New, -MaximizeBox
	
	Gui, About:Font, s24 bold
	Gui, About:Add, Text, , % Settings.programTitle
	
	Gui, About:Margin, , 0
	Gui, About:Font
	Gui, About:Add, Text, , % (Build.version ? "v" Build.version : "AutoHotkey script")
									. ", " (A_PtrSize * 8) "-bit"
									. (Settings.debug ? ", Debug enabled" : "")
									. (A_IsCompiled ? "" : ", not compiled")
									. (A_IsAdmin ? "" : ", not running as administrator") ; shouldn't ever display
	
	Gui, About:Add, Text, , Copyright (c) Ben Allred
	
	Gui, About:Margin, , 10
	Gui, About:Font, s12
	Gui, About:Add, Text, , % Settings.programDescription
	Gui, About:Add, Link, , Website: <a href="https://github.com/benallred/SnapX">https://github.com/benallred/SnapX</a>
	
	Gui, About:Margin, , 18
	Gui, About:Show, , % Settings.programTitle
}

AboutGuiEscape(hwnd)
{
	Gui, About:Destroy
}

Tray_Update(itemName, itemPos, menuName)
{
	updateFound := CheckForUpdates()
	
	if (!updateFound)
	{
		MsgBox, 0x40, % Settings.programTitle " Up To Date", % "You are running the latest version of " Settings.programTitle "." ; 0x40 = Info
	}
}

Tray_Settings(itemName, itemPos, menuName)
{
	Run, % "notepad.exe " Settings.iniFile
}

Tray_Reload(itemName, itemPos, menuName)
{
	Reload
}

Tray_Suspend(itemName, itemPos, menuName)
{
	if (A_IsSuspended)
	{
		Menu, Tray, Rename, Res&ume, S&uspend
		Menu, Tray, Icon, S&uspend, shell32.dll, 145
	}
	else
	{
		Menu, Tray, Rename, S&uspend, Res&ume
		Menu, Tray, Icon, Res&ume, shell32.dll, 302
	}
	
	Suspend, Toggle
}

Tray_Exit(itemName, itemPos, menuName)
{
	ExitApp
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper Functions

CheckForUpdates()
{
	global Build
	
	updateFound := false
	latestRelease := ""
Debug.write("Checking for updates")
	
	try
	{
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", "https://raw.githubusercontent.com/benallred/SnapX/master/Build.ahk", true)
		whr.Send()
		whr.WaitForResponse(10)
		latestRelease := whr.ResponseText
Debug.write("GET succeeded")
	}
	catch
	{
Debug.write("GET failed")
	}
	
Debug.write("Latest: " latestRelease)
	
	if (InStr(latestRelease, "Build := ", true) == 1)
	{
		RegExMatch(latestRelease, "O)version\s*:\s*""(.+?)""", match)
		newVersion := match.Value(1)
Debug.write("Old version: " Build.version)
Debug.write("New version: " newVersion)

		if (newVersion != Build.version)
		{
			updateFound := true
			MsgBox, 0x44, % Settings.programTitle " Update Available", % Settings.programTitle " version " newVersion " is available.`n`nWould you like to open the download page now?" ; 0x4 = Yes/No; 0x40 = Info
			IfMsgBox Yes
			{
				Run, https://github.com/benallred/SnapX/releases/latest
			}
		}
	}
	
	Settings.lastUpdateCheck := A_Now
	Settings.WriteSetting("lastUpdateCheck", "Updates")
	
	return updateFound
}

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper Classes

class SizeOf
{
	static UInt := 32 // 8
	static Int := 32 // 8
	static Long := SizeOf.Int
	static Point := SizeOf.Long * 2
	static Rect := SizeOf.Long * 4
	static Short := 16 // 8
	static Variant_Bool := SizeOf.Short
}

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
;Debug.write("x:" this.x " y:" this.y " w:" this.w " h:" h " r:" this.r " b:" this.b)
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

;Debug.write("a.x:" this.area.x " a.y:" this.area.y " a.w:" this.area.w " a.h:" this.area.h " a.r:" this.area.r " a.b:" this.area.b)
;Debug.write("a.x:" this.workarea.x " a.y:" this.workarea.y " a.w:" this.workarea.w " a.h:" this.workarea.h " a.r:" this.workarea.r " a.b:" this.workarea.b)
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
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#include Include\WinGetPosEx.ahk
#include Include\Const_WinUser.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Notes
;; #=Win; ^=Ctrl; +=Shift; !=Alt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants

null =
ProgramTitle := "SnapX"
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
TrayTip, % ProgramTitle, Loaded, 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Settings

iniFile := ProgramTitle ".ini"

IfNotExist %iniFile%
{
	FileAppend, % ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;`n", % iniFile
	FileAppend, % ";; Make sure to reload " ProgramTitle " after making changes (right-click tray menu > Reload).`n", % iniFile
	FileAppend, % ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;`n", % iniFile
}

IniRead, debug, %iniFile%, Settings, debug, 0

IniRead, horizontalSections, %iniFile%, Settings, horizontalSections, 0

if (!horizontalSections || horizontalSections < 2)
{
	SetTimer, ChangeButtonNames_HorizontalSections, 50
	MsgBox, 4, %ProgramTitle% Settings, This is your first time running %ProgramTitle%, by Ben Allred.`n`nPlease select your desired horizontal grid size.`n`nThis setting can be changed via the %iniFile% file.`n(Access this via the icon in the system tray.)
	IfMsgBox, Yes
		horizontalSections := 4
	else ; No
		horizontalSections := 3

	IniWrite, %horizontalSections%, %iniFile%, Settings, horizontalSections
}

IniRead, verticalSections, %iniFile%, Settings, verticalSections, 0

if (!verticalSections || verticalSections < 1)
{
	verticalSections := 1
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tray Menu

Menu, Tray, Add, % ProgramTitle, Tray_About
Menu, Tray, Icon, % ProgramTitle, shell32.dll, 160
;Menu, Tray, Disable, % ProgramTitle
Menu, Tray, Add, &About, Tray_About
Menu, Tray, Icon, &About, shell32.dll, 222 ; other options: 155, 176, 211, 222, 225, 278
Menu, Tray, Add
Menu, Tray, Add, &Settings, Tray_Settings
Menu, Tray, Icon, &Settings, shell32.dll, 316
Menu, Tray, Add, &Reload, Tray_Reload
Menu, Tray, Icon, &Reload, shell32.dll, 239
Menu, Tray, Add, S&uspend, Tray_Suspend
Menu, Tray, Icon, S&uspend, shell32.dll, 145 ; other options: 238, 220
Menu, Tray, Add, E&xit, Tray_Exit
Menu, Tray, Icon, E&xit, shell32.dll, 132
Menu, Tray, Default, % ProgramTitle
Menu, Tray, Tip, % ProgramTitle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup

if (debug)
{
	global DebugInfo
	CreateDebugWindow()
}

TrackedWindows := []
LastOperation := Operation.None
LastWindowHandle := -1
StillHoldingWinKey := 0

OnExit("ExitFunc")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hotkeys

#If debug
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
	global TrackedWindows, LastOperation, LastWindowHandle, StillHoldingWinKey, horizontalSections, verticalSections
	
	; state: minimized and LWin not released yet
	if (LastOperation == Operation.Minimized && StillHoldingWinKey)
	{
Debug("state: minimized")
		; action: win+up
		if (horizontalSize > 0)
		{
Debug("   action: restore")
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
Debug("state: restored")
Debug("   action: minimize")
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
	widthFactor  := mon.workarea.w / horizontalSections
	heightFactor := mon.workarea.h / verticalSections
	
	; state: minimized
	if (minMaxState < 0)
	{
Debug("state: minimized")
		; action: win+up
		if (horizontalSize > 0)
		{
Debug("   action: restore")
			LastOperation := Operation.Restored
			WinRestore, A
		}
		; action: anything else
		return
	}
	
	; state: maximized
	else if (minMaxState > 0)
	{
Debug("state: maximized")
		; action: win+down
		if (horizontalSize < 0)
		{
Debug("   action: restore snapped")
			LastOperation := Operation.RestoredSnapped
			WinRestore, A
		}
		; action: anything else
		return
	}
	
	; state: snapped
	else if (window.snapped == 1)
	{
Debug("state: snapped")
		; state: width == max - 1
		if (window.grid.width >= horizontalSections - 1)
		{
			; action: win+up
			if (horizontalSize > 0)
			{
Debug("   action: maximize")
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
Debug("   action: restore unsnapped")
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
Debug("   action: " (horizontalDirection ? "move" : horizontalSize ? "resize" : "what?"))
		LastOperation := Operation.Moved
		window.grid.left := window.grid.left + horizontalDirection
		window.grid.left := window.grid.left + (horizontalSize < 0 && window.grid.left + window.grid.width >= horizontalSections ? 1 : 0) ; keep right edge attached to monitor edge if shrinking
		window.grid.top := 0
		window.grid.width := window.grid.width + horizontalSize
		window.grid.height := 1
	}
	
	; state: restored
	else if (window.snapped == 0)
	{
Debug("state: restored")
		; action: win+down
		if (horizontalSize < 0)
		{
			; state: minimizable
			if (activeWindowStyle & WS.MINIMIZEBOX) ; if window is minimizable
			{
Debug("   action: minimize")
				MinimizeAndKeyWaitLWin()
			}
			return
		}
		
		window.UpdatePosition()
		
		; action: anything else
Debug("   action: snap")
		LastOperation := Operation.Snapped
		window.snapped := 1
; Snap based on left/right edges and left/right direction pushed
		window.grid.left := Floor(((horizontalDirection < 0 ? window.position.x : horizontalDirection > 0 ? window.position.r : window.position.cx) - mon.workarea.x) / mon.workarea.w * horizontalSections)
; Original - Snap based on center coordinates
;		window.grid.left := Floor((window.position.cx - mon.workarea.x) / mon.workarea.w * horizontalSections)
; Always snaps to current centercoords position, regardless of snap direction pushed
;		(do nothing more)
; Does not snap to current centercoords position - always left or right of current centercoords (unless against edge, of course)
;		window.grid.left := window.grid.left + horizontalDirection
; Shift one more snap direction if starting snap position is on opposite side of the screen from indicated direction
;		window.grid.left := window.grid.left
;									+ ((horizontalSections - 1) / 2 - window.grid.left > 0 == horizontalDirection > 0 ; if snap position is on the opposite side of the screen as horizontal direction pushed (snap is 0 or 1 and win+right pushed; or snap is 2 or 3 and win+left pushed)
;										|| (horizontalSections - 1) / 2 - window.grid.left == 0 ; or if snap position is exact center (forward-compatibility for allowing horizontalSections == 3 (or any odd number))
;										 ? horizontalDirection ; shift one more snap indicated direction
;										 : 0)
; Always snap against edge in direction pushed
;		window.grid.left := horizontalDirection < 0 ? 0 : horizontalDirection > 0 ? horizontalSections - 1 : window.grid.left
; Always snap against center edge in direction pushed
;		window.grid.left := horizontalDirection < 0 ? horizontalSections // 2 - 1 : horizontalDirection > 0 ? (horizontalSections + 1) // 2 : window.grid.left
		window.grid.top := 0
		window.grid.width := 1 + horizontalSize
		window.grid.height := 1
		window.restoredpos.left   := (window.position.x - mon.workarea.x) / mon.workarea.w
		window.restoredpos.top    := (window.position.y - mon.workarea.y) / mon.workarea.h
		window.restoredpos.width  :=  window.position.w                   / mon.workarea.w
		window.restoredpos.height :=  window.position.h                   / mon.workarea.h
	}
	
	; Enforce snap boundaries
	
	if window.grid.left + window.grid.width > horizontalSections
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
	
	TrayTip, % ProgramTitle, Resetting snapped windows to their pre-snap size and position
	
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
	Global ProgramTitle, Build, debug
	
	Gui, About:New, -MaximizeBox
	
	Gui, About:Font, s24 bold
	Gui, About:Add, Text, , % ProgramTitle
	
	Gui, About:Margin, , 0
	Gui, About:Font
	Gui, About:Add, Text, , % (Build.version ? "v" Build.version : "AutoHotkey script")
									. ", " (A_PtrSize * 8) "-bit"
									. (debug ? ", Debug enabled" : "")
									. (A_IsCompiled ? "" : ", not compiled")
									. (A_IsAdmin ? "" : ", not running as administrator") ; shouldn't ever display
	
	Gui, About:Add, Text, , Copyright (c) Ben Allred
	
	Gui, About:Margin, , 10
	Gui, About:Font, s12
	Gui, About:Add, Text, , Replacement for Windows/Aero Snap.
	Gui, About:Add, Link, , Website: <a href="https://github.com/benallred/SnapX">https://github.com/benallred/SnapX</a>
	
	Gui, About:Margin, , 18
	Gui, About:Show, , % ProgramTitle
}

AboutGuiEscape(hwnd)
{
	Gui, About:Destroy
}

Tray_Settings(itemName, itemPos, menuName)
{
	global iniFile
	Run, notepad.exe %iniFile%
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

ChangeButtonNames_HorizontalSections:
	IfWinNotExist, %ProgramTitle% Settings
		return
	SetTimer, ChangeButtonNames_HorizontalSections, Off
	WinActivate
	ControlSetText, Button1, &4
	ControlSetText, Button2, &3
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper Functions

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
		if ((itemProperty <> null && item[itemProperty] = value) || item = value)
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
;Debug("x:" this.x " y:" this.y " w:" this.w " h:" h " r:" this.r " b:" this.b)
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

;Debug("a.x:" this.area.x " a.y:" this.area.y " a.w:" this.area.w " a.h:" this.area.h " a.r:" this.area.r " a.b:" this.area.b)
;Debug("a.x:" this.workarea.x " a.y:" this.workarea.y " a.w:" this.workarea.w " a.h:" this.workarea.h " a.r:" this.workarea.r " a.b:" this.workarea.b)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Debug

CreateDebugWindow()
{
	global ProgramTitle
	Gui, +AlwaysOnTop
	Gui, Add, ListView, vDebugInfo r20 w300 -Hdr, DebugId|Debug Info
	Gui, Show, x10 y10, %ProgramTitle% Debug Info
}

Debug(text)
{
	lastRow := LV_Add("", , text)
	LV_Modify(lastRow, "Vis", lastRow)
	LV_ModifyCol(1, "Auto")
}

DebugArray(array, itemProperty)
{
	local i
	local item
	local s
	s := ""
	for i, item in array
	{
		if (s <> "")
		{
			s := s ", "
		}
		
		s := s item[itemProperty]
	}
	Debug(s)
}
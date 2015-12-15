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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Startup

if not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}

SoundPlay *64
TrayTip, % ProgramTitle, Loaded, 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read settings
iniFile := ProgramTitle ".ini"

IniRead, debug, %iniFile%, Settings, debug, 0

IniRead, horizontalSections, %iniFile%, Settings, horizontalSections, 0

if (!horizontalSections)
{
	SetTimer, ChangeButtonNames_HorizontalSections, 50
	MsgBox, 4, %ProgramTitle% Settings, This is your first time running %ProgramTitle%, by Ben Allred.`n`nPlease select your desired horizontal grid size.`n`nThis setting can be changed via the %iniFile% file.
	IfMsgBox, Yes
		horizontalSections := 4
	else ; No
		horizontalSections := 3

	IniWrite, %horizontalSections%, %iniFile%, Settings, horizontalSections
}

IniRead, verticalSections, %iniFile%, Settings, verticalSections, 0

if (!verticalSections)
{
	verticalSections := 1
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (debug)
{
	global DebugInfo
	CreateDebugWindow()
}

TrackedWindows := []

OnExit("ExitFunc")

#`::Reload ; for ease of testing during development

#Left::MoveWindow(-1, 0)

#Right::MoveWindow(1, 0)

#Up::MoveWindow(0, 1)

#Down::MoveWindow(0, -1)

MoveWindow(horizontalDirection, horizontalSize)
{
	global TrackedWindows, horizontalSections, verticalSections
	
	WinGet, activeWindowHandle, ID, A
	
	WinGet, activeWindowStyle, Style, A
	
	if (!(activeWindowStyle & WS.SIZEBOX)) ; if window is not resizable
	{
		return
	}

	index := IndexOf(TrackedWindows, activeWindowHandle, "handle")
	if index < 1
	{
		window := new SnapWindow(activeWindowHandle)
		index := TrackedWindows.Push(window)
	}
	
	window := TrackedWindows[index]
	
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
				WinMove, A, , window.restoredpos.left   * mon.workarea.w + mon.area.x
								, window.restoredpos.top    * mon.workarea.h + mon.area.y
								, window.restoredpos.width  * mon.workarea.w
								, window.restoredpos.height * mon.workarea.h ; "restore" from snapped state
				return
			}
			; action: anything else
			; (continue)
		}
		
		; action: all
Debug("   action: " (horizontalDirection ? "move" : horizontalSize ? "resize" : "what?"))
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
Debug("   action: minimize")
			WinMinimize, A
			return
		}
		
		window.UpdatePosition()
		
		; action: anything else
Debug("   action: snap")
		window.snapped := 1
; Snap based on left/right edges and left/right direction pushed
		window.grid.left := Floor(((horizontalDirection < 0 ? window.position.x : horizontalDirection > 0 ? window.position.r : window.position.cx) - mon.area.x) / mon.workarea.w * horizontalSections)
; Original - Snap based on center coordinates
;		window.grid.left := Floor((window.position.cx - mon.area.x) / mon.workarea.w * horizontalSections)
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
		window.restoredpos.left   := (window.position.x - mon.area.x) / mon.workarea.w
		window.restoredpos.top    := (window.position.y - mon.area.y) / mon.workarea.h
		window.restoredpos.width  :=  window.position.w               / mon.workarea.w
		window.restoredpos.height :=  window.position.h               / mon.workarea.h
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
	WinMove, A, , window.grid.left   * widthFactor  +    window.position.xo + mon.area.x
					, window.grid.top    * heightFactor                         + mon.area.y
					, window.grid.width  * widthFactor  + -2*window.position.xo
					, window.grid.height * heightFactor + -1*window.position.xo ; + -2*window.position.yo + 1
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
			
			WinGet, minMaxState, MinMax, A
			
			WinRestore, % "ahk_id " window.handle
			WinMove, % "ahk_id " window.handle, , window.restoredpos.left   * mon.workarea.w + mon.area.x
															, window.restoredpos.top    * mon.workarea.h + mon.area.y
															, window.restoredpos.width  * mon.workarea.w
															, window.restoredpos.height * mon.workarea.h ; "restore" from snapped state
			
			; state: maximized
			if (minMaxState > 0)
			{
				WinMaximize, % "ahk_id " window.handle
			}
		}
	}
}

ChangeButtonNames_HorizontalSections:
	IfWinNotExist, %ProgramTitle% Settings
		return
	SetTimer, ChangeButtonNames_HorizontalSections, Off
	WinActivate
	ControlSetText, Button1, 4
	ControlSetText, Button2, 3
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper Functions

GetMonitorId(hwnd)
{
	local monArea, monAreaLeft, monAreaRight, monAreaTop, monAreaBottom
	local winX, winY, winW, winH, winR, winB, winCenterX, winCenterY
	
	WinGetPos, winX, winY, winW, winH, % "ahk_id " hwnd
	winR := winX + winW
	winB := winY + winH
	winCenterX := winX + winW / 2
	winCenterY := winY + winH / 2
	
	SysGet, monitorCount, MonitorCount
	
	Loop, % monitorCount
	{
		SysGet, monArea, Monitor, % A_Index
		
		if (winCenterX >= monAreaLeft && winCenterX <= monAreaRight && winCenterY >= monAreaTop && winCenterY <= monAreaBottom)
		{
			return % A_Index
		}
	}
	
	return 1
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
		this.workarea := new SizePosition(monWorkAreaLeft, monWorkAreaTop, , , monWorkAreaRight, monWorkAreaBottom)

;Debug("monitor:" this.id " a.x:" this.area.x " a.y:" this.area.y " a.w:" this.area.w " a.h:" this.area.h " a.r:" this.area.r " a.b:" this.area.b)
;Debug("monitor:" this.id " wa.x:" this.workarea.x " wa.y:" this.workarea.y " wa.w:" this.workarea.w " wa.h:" this.workarea.h " wa.r:" this.workarea.r " wa.b:" this.workarea.b)
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
	Gui, +AlwaysOnTop
	Gui, Add, ListBox, vDebugInfo w300 h1100
	Gui, Show, x10 y10
}

Debug(text)
{
	GuiControl, , DebugInfo, % text
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
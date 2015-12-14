#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#include Include\WinGetPosEx.ahk
#include Include\Windy\Windy.ahk

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

global DebugInfo
CreateDebugWindow()

TrackedWindows := []

;OnExit("ExitFunc")

#`::Reload ; for ease of testing during development

#Left::MoveWindow(-1, 0)

#Right::MoveWindow(1, 0)

#Up::MoveWindow(0, 1)

#Down::MoveWindow(0, -1)

MoveWindow(horizontalDirection, horizontalSize)
{
	global TrackedWindows
	
	WinGet, activeWindowHandle, ID, A
	
	isRealWindow := windy.__isWindow(activeWindowHandle)
	if (isRealWindow == 0)
	{
		return
	}

	index := IndexOf(TrackedWindows, activeWindowHandle, "hwnd")
	if index < 1
	{
		windy := new Windy(activeWindowHandle)
		; snap.left is in grid coordinates
		; snap.pre.left is in percentage of monitor
		windy.snap := { snapped:0, left:0, top:0, width:0, height:0, pre:{ left:0.0, top:0.0, width:0.0, height:0.0 } }
		index := TrackedWindows.Push(windy)
	}
	
	windy := TrackedWindows[index]
	mony := new Mony(windy.monitorID)
	WinGetPosEx(activeWindowHandle, , , , , xOffset, yOffset)
	WinGet, minMaxState, MinMax, A
	horizontalSections := 4
	widthFactor := mony.workingArea.w / horizontalSections
	heightFactor := mony.workingArea.h / 1
	
	; state: minimized
	if (minMaxState < 0)
	{
		; action: win+up
		if (horizontalSize > 0)
		{
			WinRestore, A
		}
		; action: anything else
		return
	}
	
	; state: maximized
	else if (minMaxState > 0)
	{
		; action: win+down
		if (horizontalSize < 0)
		{
			WinRestore, A
		}
		; action: anything else
		return
	}
	
	; state: snapped
	else if (windy.snap.snapped == 1)
	{
		; state: width == max - 1
		if (windy.snap.width >= horizontalSections - 1)
		{
			; action: win+up
			if (horizontalSize > 0)
			{
				WinMaximize, A
				return
			}
			; action: anything else
			; (continue)
		}
		
		; state: width == 1
		if (windy.snap.width == 1)
		{
			; action: win+down
			if (horizontalSize < 0)
			{
				windy.snap.snapped := 0
				WinMove, A, , windy.snap.pre.left   * mony.workingArea.w + mony.boundary.xul
								, windy.snap.pre.top    * mony.workingArea.h + mony.boundary.yul
								, windy.snap.pre.width  * mony.workingArea.w
								, windy.snap.pre.height * mony.workingArea.h ; "restore" from snapped state
				return
			}
			; action: anything else
			; (continue)
		}
		
		; action: all
		windy.snap.left := windy.snap.left + horizontalDirection
		windy.snap.top := 0
		windy.snap.width := windy.snap.width + horizontalSize
		windy.snap.height := 1
	}
	
	; state: restored
	else if (windy.snap.snapped == 0)
	{
		; action: win+down
		if (horizontalSize < 0)
		{
			WinMinimize, A
			return
		}
		
		; action: anything else
		windy.snap.snapped := 1
; Snap based on left/right edges and left/right direction pushed
		windy.snap.left := Floor(((horizontalDirection < 0 ? windy.posSize.xul : horizontalDirection > 0 ? windy.posSize.xlr : windy.centercoords.x) - mony.boundary.xul) / mony.workingArea.w * horizontalSections)
; Original - Snap based on center coordinates
;		windy.snap.left := Floor((windy.centercoords.x - mony.boundary.xul) / mony.workingArea.w * horizontalSections)
; Always snaps to current centercoords position, regardless of snap direction pushed
;		(do nothing more)
; Does not snap to current centercoords position - always left or right of current centercoords (unless against edge, of course)
;		windy.snap.left := windy.snap.left + horizontalDirection
; Shift one more snap direction if starting snap position is on opposite side of the screen from indicated direction
;		windy.snap.left := windy.snap.left
;									+ ((horizontalSections - 1) / 2 - windy.snap.left > 0 == horizontalDirection > 0 ; if snap position is on the opposite side of the screen as horizontal direction pushed (snap is 0 or 1 and win+right pushed; or snap is 2 or 3 and win+left pushed)
;										|| (horizontalSections - 1) / 2 - windy.snap.left == 0 ; or if snap position is exact center (forward-compatibility for allowing horizontalSections == 3 (or any odd number))
;										 ? horizontalDirection ; shift one more snap indicated direction
;										 : 0)
; Always snap against edge in direction pushed
;		windy.snap.left := horizontalDirection < 0 ? 0 : horizontalDirection > 0 ? horizontalSections - 1 : windy.snap.left
; Always snap against center edge in direction pushed
;		windy.snap.left := horizontalDirection < 0 ? horizontalSections // 2 - 1 : horizontalDirection > 0 ? (horizontalSections + 1) // 2 : windy.snap.left
		windy.snap.top := 0
		windy.snap.width := 1 + horizontalSize
		windy.snap.height := 1
		windy.snap.pre.left   := (windy.posSize.x - mony.boundary.xul) / mony.workingArea.w
		windy.snap.pre.top    := (windy.posSize.y - mony.boundary.yul) / mony.workingArea.h
		windy.snap.pre.width  :=  windy.posSize.w                      / mony.workingArea.w
		windy.snap.pre.height :=  windy.posSize.h                      / mony.workingArea.h
	}
	
	; Enforce snap boundaries
	
	if windy.snap.left + windy.snap.width > horizontalSections
	{
		windy.snap.left := windy.snap.left - 1
	}
	
	if windy.snap.left < 0
	{
		windy.snap.left := 0
	}
	
	; Move/resize snap
	WinMove, A, , windy.snap.left   * widthFactor  +    xOffset + mony.boundary.xul
					, windy.snap.top    * heightFactor              + mony.boundary.yul
					, windy.snap.width  * widthFactor  + -2*xOffset
					, windy.snap.height * heightFactor + -1*xOffset ; + -2*yOffset + 1
}

ExitFunc(exitReason, exitCode)
{
	local i
	local windy
	TrayTip, % ProgramTitle, Resetting snapped windows to their pre-snap size and position
	for i, windy in TrackedWindows
	{
		; state: snapped
		if (windy.snap.snapped == 1)
		{
			mony := new Mony(windy.monitorID)
			WinMove, % "ahk_id " windy.hwnd, , windy.snap.pre.left   * mony.workingArea.w + mony.boundary.xul
														, windy.snap.pre.top    * mony.workingArea.h + mony.boundary.yul
														, windy.snap.pre.width  * mony.workingArea.w
														, windy.snap.pre.height * mony.workingArea.h ; "restore" from snapped state
		}
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper Functions

IndexOf(array, value, itemProperty = "")
{
	local i
	local item
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
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
		; snap.pre.left is in pixels
		windy.snap := { snapped:0, left:0, top:0, width:0, height:0, pre:{ left:0, top:0, width:0, height:0 } }
		index := TrackedWindows.Push(windy)
	}
	
	windy := TrackedWindows[index]
	mony := new Mony(windy.monitorID)
	WinGetPosEx(activeWindowHandle, , , , , xOffset, yOffset)
	WinGet, minMaxState, MinMax, A
	horizontalSections := 4
	widthFactor := mony.workingArea.w / horizontalSections
	heightFactor := mony.workingArea.h / 1
	
	if (minMaxState < 0)
	{
		if (horizontalSize > 0)
		{
			WinRestore, A
		}
		return
	}
	else if (horizontalSize < 0)
	{
		if (windy.snap.snapped == 0)
		{
			WinMinimize, A
			return
		}
		else if (minMaxState == 1)
		{
			WinRestore, A
			return
		}
	}
	else if (horizontalSize > 0 && windy.snap.width >= horizontalSections - 1)
	{
		WinMaximize, A
		return
	}
	
	if windy.snap.snapped == 1
	{
		windy.snap.left := windy.snap.left + horizontalDirection
		windy.snap.top := 0
		windy.snap.width := windy.snap.width + horizontalSize
		windy.snap.height := 1
	}
	else
	{
		windy.snap.snapped := 1
		windy.snap.left := Floor((windy.centercoords.x - mony.boundary.xul) / mony.workingArea.w * horizontalSections)
		windy.snap.top := 0
		windy.snap.width := 1 + horizontalSize
		windy.snap.height := 1
		windy.snap.pre.left := windy.posSize.x
		windy.snap.pre.top := windy.posSize.y
		windy.snap.pre.width := windy.posSize.w
		windy.snap.pre.height := windy.posSize.h
	}
	
	if windy.snap.left + windy.snap.width > horizontalSections
	{
		windy.snap.left := windy.snap.left - 1
	}
	
	if windy.snap.left < 0
	{
		windy.snap.left := 0
	}
	
	if windy.snap.width < 1
	{
		windy.snap.width := 1
		windy.snap.snapped := 0
	}
	
	if windy.snap.left >= horizontalSections
	{
		windy.snap.left := horizontalSections - 1
	}
	
	if windy.snap.snapped
	{
		WinMove, A, , windy.snap.left * widthFactor + xOffset + mony.boundary.xul, windy.snap.top * heightFactor + mony.boundary.yul, windy.snap.width * widthFactor + -2*xOffset, windy.snap.height * heightFactor + -1*xOffset ; + -2*yOffset + 1
	}
	else
	{
		WinMove, A, , windy.snap.pre.left, windy.snap.pre.top, windy.snap.pre.width, windy.snap.pre.height
	}
}

ExitFunc(exitReason, exitCode)
{
	local i
	local windy
	TrayTip, % ProgramTitle, Resetting snapped windows to their pre-snap size and position
	for i, windy in TrackedWindows
	{
		WinMove, % "ahk_id " windy.hwnd, , windy.snap.pre.left, windy.snap.pre.top, windy.snap.pre.width, windy.snap.pre.height
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
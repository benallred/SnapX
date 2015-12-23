#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Third-party libraries

#Include Include\WinGetPosEx.ahk
#Include Include\Const_WinUser.ahk

; SnapX modules

#Include Modules\Settings.ahk
#Include Modules\Debug.ahk
#Include Modules\Updates.ahk
#Include Modules\Tray.ahk
#Include Modules\Functions.ahk
#Include Modules\Classes.ahk
#Include Modules\Snapper.ahk

#Include Build.ahk

; Startup

Tray.initIcon()

if not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}

SoundPlay *64
TrayTip, % Settings.programTitle, Loaded

settings := new Settings()
debug := new Debug(settings)
updateChecker := new UpdateChecker(settings, Build)
tray := new Tray(settings, Build, updateChecker)
snapper := new Snapper(settings)

; Hotkeys

#If settings.debug
#`::Reload ; for ease of testing during development
#If

#Left::snapper.moveWindow(-1, 0)

#Right::snapper.moveWindow(1, 0)

#Up::snapper.moveWindow(0, 1)

#Down::snapper.moveWindow(0, -1)
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include Include\WinGetPosEx.ahk
#Include Include\Const_WinUser.ahk

#Include Modules\Settings.ahk
#Include Modules\Debug.ahk
#Include Modules\Updates.ahk
#Include Modules\Tray.ahk
#Include Modules\Functions.ahk
#Include Modules\Classes.ahk
#Include Modules\Snapper.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants

Build := { version: "" }
#Include *i Build.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Startup

Tray.InitIcon()

if not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}

SoundPlay *64
TrayTip, % Settings.programTitle, Loaded

Settings := new Settings()
Debug := new Debug(Settings)
UpdateChecker := new UpdateChecker(Settings, Build)
Tray := new Tray(Settings, Build, UpdateChecker)
Snapper := new Snapper(Settings)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hotkeys

#If Settings.debug
#`::Reload ; for ease of testing during development
#If

#Left::Snapper.MoveWindow(-1, 0)

#Right::Snapper.MoveWindow(1, 0)

#Up::Snapper.MoveWindow(0, 1)

#Down::Snapper.MoveWindow(0, -1)
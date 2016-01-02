#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; ahk2exe directives (http://fincs.ahk4.net/Ahk2ExeDirectives.htm)

; icon 1
;@Ahk2Exe-SetMainIcon Resources\SnapX.ico
;@Ahk2Exe-SetCopyright Copyright © Ben Allred
;@Ahk2Exe-SetCompanyName Ben Allred
;@Ahk2Exe-SetOrigFilename SnapX.exe
; @ Ahk2Exe-SetName			; this is set in Settings.ahk
; @ Ahk2Exe-SetDescription	; this is set in Settings.ahk
; @ Ahk2Exe-SetVersion		; this is set in Build.ahk

; icon 6
;@Ahk2Exe-AddResource Resources\About.ico
; icon 7
;@Ahk2Exe-AddResource Resources\Update.ico
; icon 8
;@Ahk2Exe-AddResource Resources\Settings.ico
; icon 9
;@Ahk2Exe-AddResource Resources\Reload.ico
; icon 10
;@Ahk2Exe-AddResource Resources\Suspend.ico
; icon 11
;@Ahk2Exe-AddResource Resources\Resume.ico
; icon 12
;@Ahk2Exe-AddResource Resources\Exit.ico
; icon 13
;@Ahk2Exe-AddResource Resources\Help.ico
; icon 14
;@Ahk2Exe-AddResource Resources\Windows.ico

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
#Include Modules\AboutGui.ahk
#Include Modules\SettingsGui.ahk
#Include Modules\HelpGui.ahk

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

#MaxThreadsBuffer On

#Left::snapper.moveWindow(-1, 0, 0, 0)
#!Left::snapper.moveWindow(-1, 0, 0, 0)
#Right::snapper.moveWindow(1, 0, 0, 0)
#!Right::snapper.moveWindow(1, 0, 0, 0)
#!Up::snapper.moveWindow(0, 0, -1, 0)
#!Down::snapper.moveWindow(0, 0, 1, 0)

#Up::snapper.moveWindow(0, 1, 0, 0)
#Down::snapper.moveWindow(0, -1, 0, 0)
#PgUp::snapper.moveWindow(0, 0, 0, 1)
#PgDn::snapper.moveWindow(0, 0, 0, -1)
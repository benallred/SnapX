SnapX
=====

Replacement for Windows/Aero Snap.

I like the built-in Snap but needed something with more options when I got a 34" monitor to replace two 24" monitors.  (I don't want to replace four horizontal snaps with two extra-wide snaps.)

#### Standards
*	Use the same shortcut keys as Snap (Win+_arrow key_) and the keys must perform the same functions
*	If a shortcut key function must be changed, the new function must be intuitively similar
*	If new shortcut keys must be introduced, the new keys must be intuitively similar to the originals

#### Usage

**Horizontal Snapping**
*	Win+Left
	*	If not snapped, snap
	*	If snapped, move snap left
*	Win+Right
	*	If not snapped, snap
	*	If snapped, move snap right
*	Win+Up
	*	If not snapped, snap and increase snap width by 1
	*	If snapped, increase snap width by 1
*	Win+Down
	*	If not snapped, minimize
	*	If snapped, decrease snap width by 1
	*	If snapped and current width is 1, restore

**Vertical Snapping**
*	Win+PgUp
	*	If not snapped, snap and adjust height towards the top of the monitor
	*	If snapped, adjust height towards the top of the monitor
*	Win+PgDn
	*	If not snapped, snap and adjust height towards the bottom of the monitor
	*	If snapped, adjust height towards the bottom of the monitor
*	Win+Alt+Up
	*	If not snapped, snap and set height to 1
	*	If snapped, move snap up
*	Win+Alt+Down
	*	If not snapped, snap and set height to 1
	*	If snapped, move snap down
*	(Win+Alt+Left/Right perform the same functions as Win+Left/Right to make omnidirectional movement more natural (don't have to press and release Alt))

#### Settings
Settings are accessible from the tray menu.

#### Credits

*	[Const_WinUser](https://github.com/hoppfrosch/AHK_Windy/blob/master/lib/Windy/Const_WinUser.ahk)
*	[WinGetPosEx](https://autohotkey.com/boards/viewtopic.php?t=3392)

--------------------------------------------------

### License

[The MIT License (MIT)](LICENSE.txt)
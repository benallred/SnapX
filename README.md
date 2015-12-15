SnapX
=====

Replacement for Windows/Aero Snap.

I like the built-in Snap but needed something with more options when I got a 34" monitor to replace two 24" monitors.  (I don't want to replace four horizontal snaps with two extra-wide snaps.)

####Standards####
*	Use the same shortcut keys as Snap (Win+_arrow key_) and the keys must perform the same functions
*	If a shortcut key function must be changed, the new function must be intuitively similar
*	If new shortcut keys must be introduced, the new keys must be intuitively similar to the originals

####Usage####
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

####Settings####
Settings are configurable on first run and from an .ini file thereafter.

####Detailed states and actions####
```
Key
	|   |   |   |   | (monitor with four snap positions)
	x (position of snapped window)
	r (restored window)
	m (minimized window)
	| x | x |   |   | (ex: window snapped left with width = 2)

Starting position     Win+Left              Win+Right             Win+Up                Win+Down
| r |   |   |   |     | x |   |   |   |     |   | x |   |   |     | x | x |   |   |     |       m       |
|   | r |   |   |     |   | x |   |   |     |   |   | x |   |     |   | x | x |   |     |       m       |
|   |   | r |   |     |   | x |   |   |     |   |   | x |   |     |   |   | x | x |     |       m       |
|   |   |   | r |     |   |   | x |   |     |   |   |   | x |     |   |   | x | x |     |       m       |

| x |   |   |   |         unchanged         |   | x |   |   |     | x | x |   |   |     | r |   |   |   |
|   | x |   |   |     | x |   |   |   |     |   |   | x |   |     |   | x | x |   |     |   | r |   |   |
|   |   | x |   |     |   | x |   |   |     |   |   |   | x |     |   |   | x | x |     |   |   | r |   |
|   |   |   | x |     |   |   | x |   |         unchanged         |   |   | x | x |     |   |   |   | r |

| x | x |   |   |         unchanged         |   | x | x |   |     | x | x | x |   |     | x |   |   |   |
|   | x | x |   |     | x | x |   |   |     |   |   | x | x |     |   | x | x | x |     |   | x |   |   |
|   |   | x | x |     |   | x | x |   |         unchanged         |   | x | x | x |     |   |   |   | x |

| x | x | x |   |         unchanged         |   | x | x | x |     | x | x | x | x |     | x | x |   |   |
|   | x | x | x |     | x | x | x |   |         unchanged         | x | x | x | x |     |   |   | x | x |

| x | x | x | x |         unchanged             unchanged             unchanged         | x | x | x |   | (depending on previous position)
| x | x | x | x |         unchanged             unchanged             unchanged         |   | x | x | x | (depending on previous position)
```

####Credits####

*	[Const_WinUser](https://github.com/hoppfrosch/AHK_Windy/blob/master/lib/Windy/Const_WinUser.ahk)
*	[WinGetPosEx](https://autohotkey.com/boards/viewtopic.php?t=3392)

--------------------------------------------------

###The MIT License (MIT)###

Copyright (c) Ben Allred

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
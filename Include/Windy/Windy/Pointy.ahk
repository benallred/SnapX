; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) ************** 

; ******************************************************************************************************************************************
/*
	Class: Pointy
	Handling points (given through [x, y])
	
	Remarks:
	### License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See [WTFPL](http://www.wtfpl.net/) for more details.
	### Author
	[hoppfrosch](hoppfrosch@gmx.me)		
	@UseShortForm
*/
class Pointy {
	
	_version := "0.2.0"
	_debug := 0 ; _DBG_	
	x := 0
	y := 0
	
	
	Dump() {
		/*! ===============================================================================
			Method: Dump()
			Dumps coordinates to a string
			Returns:
			printable string containing coordinates
			Remarks:
			### Author(s)
			* 20140908 - [hoppfrosch](hoppfrosch@gmx.de) - Original
		*/
		return "(" this.x "," this.y ")"
	}
	
	equal(comp) {
		/*! ===============================================================================
			Method: equal(comp)
			Compares currrent point to given point
			Parameters:
			comp - [Point](Pointy.html) to compare with
			Returns:
			true or false
			Remarks:
			### Author(s)
			* 20140908 - [hoppfrosch](hoppfrosch@gmx.de) - Original
		*/
		return (this.x == comp.x) AND (this.y == comp.y)
	}
	
	fromHWnd(hwnd) {
		/*! ===============================================================================
			Method: fromHWnd(hwnd)
			Fills values from given Window (given by Handle)
			Parameters:
			hWnd - Window handle, whose upper left corner has to be determined
			Remarks:				
			### Author(s)
			* 20140908 - [hoppfrosch](hoppfrosch@gmx.de) - Original
		*/
		WinGetPos, x, y, w, h, ahk_id %hwnd%
		this.x := x
		this.y := y
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "([" hwnd "])] -> x,y: (" x "," y ")" ; _DBG_
		
		return this
	}
	
	fromMouse() {
		/*! ===============================================================================
			Method: fromMouse(hwnd)
			Fills values from current Mouseposition
			Remarks:		
			### Author(s)
			* 20140908 - [hoppfrosch](hoppfrosch@gmx.de) - Original
		*/
		CoordMode, Mouse, Screen
		MouseGetPos, x, y
		this.x := x
		this.y := y
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "([" hwnd "])] -> x,y: (" x "," y ")" ; _DBG_
		
		return this
	}
	
	fromPoint(new) {
		/*! ===============================================================================
			Method: fromPoint(new)
			Fills values from given [Point](Pointy.html)
			Parameters:
			new - Point
			Remarks:
			### Author(s)
			* 20140908 - [hoppfrosch](hoppfrosch@gmx.de) - Original
		*/
		
		this.x := new.x 
		this.y := new.y
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "] -> x,y: " this.Dump() ; _DBG_
		
		return this
	}
	
	__debug(value="") { ; _DBG_
		/*! ===============================================================================
			Method:__debug()
			Set or get the debug flag (*INTERNAL*)
			Parameters:
			value - Value to set the debug flag to (OPTIONAL)
			Returns:
			true or false, depending on current value
			Remarks:
			### Author(s)
			* 20140908 - [hoppfrosch](hoppfrosch@gmx.de) - Original
		*/
		if % (value="") ; _DBG_
			return this._debug ; _DBG_
		value := value<1?0:1 ; _DBG_
		this._debug := value ; _DBG_
		return this._debug ; _DBG_
	} ; _DBG_
	
	/*
		===============================================================================
		Function: __New
		Constructor (*INTERNAL*)
		
		Parameters:
		x,y - X,Y of the point
		debug - Flag to enable debugging (Optional - Default: 0)
		
		Author(s):
		* 20140908 - [hoppfrosch](hoppfrosch@gmx.de) - Original
		===============================================================================
	*/     
	__New(x=0, y=0, debug=false) {
		this._debug := debug ; _DBG_
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(x=" x ", y=" y ", _debug=" debug ")] (version: " this._version ")" ; _DBG_
		this.x := x
		this.y := y
	}
}

/*!
	End of class
*/

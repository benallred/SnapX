; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) ************** 

class Recty {
; ******************************************************************************************************************************************
/*
	Class: Recty
		Handling rectangles (given through [x, y (upper-left corner), w, h] or [x, y (upper-left corner), x, y (lower-right corner)])
		
	Author(s):
	<hoppfrosch at hoppfrosch@gmx.de>		

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.

*/
	_version := "0.3.0"
	_debug := 0 ; _DBG_	
	x := 0
	y := 0
	w := 0
	h := 0

	Dump() {
	/* ===============================================================================
	Method: Dump
		Dumps coordinates to a string

	Returns:
		printable string containing coordinates
	*/

		return "(" this.x "," this.y "," this.w "," this.h ")"
	}
	equal(comp) {
	/* ===============================================================================
	Method: equal
		Compares currrent rectangle to given rectangle

	Parameters:
		comp - <Rectangle at Recty.html> to compare with

	Returns:
		true or false

	See also: 
		<equalPos at #equalPos>, <equalSize at #equalSize>
	*/

		return this.equalPos(comp) AND this.equalSize(comp)
	}
	equalPos(comp) {
	/* ===============================================================================
	Method: equalPos
		Compares currrent rectangle position to given rectangle position
		
	Parameters:
		comp - <Rectangle at Recty.html> to compare with

	Returns:
		true or false

	See also: 
		<equal at #equal>, <equalSize at #equalSize>
	*/

		return (this.x == comp.x) AND (this.y == comp.y)
	}
	equalSize(comp) {
	/* ===============================================================================
	Method: equalSize
		Compares currrent rectangle size to given rectangle size
		
	Parameters:
		comp - <Rectangle at Recty.html> to compare with
		
	Returns:
		true or false

	See also: 
		<equal at #equal>, <equalPos at #equalPos>	
	*/
		ret := (this.w == comp.w)  AND (this.h == comp.h)
		return ret
	}
	fromHWnd(hwnd) {
	/* ===============================================================================
	Method: fromHWnd(hwnd)
		Fills values from given Window (given by Handle)

	Parameters:
		hWnd - Window handle, whose geometry has to be determined

	See also: 
		<fromWinPos at #fromWinPos>
	*/
		WinGetPos, x, y, w, h, ahk_id %hwnd%
		this.x := x
		this.y := y
		this.w := w
		this.h := h
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "([" hwnd "])] -> x,y,w,h: (" x "," y "," w "," h ")" ; _DBG_
	}
	fromRectangle(new) {
	/*! ===============================================================================
	Method: fromRectangle(new)
		Fills values from given <Rectangle at Recty.html>

	Parameters:
		new - Rectangle
	*/
		this.x := new.x 
		this.y := new.y
		this.w := new.w
		this.h := new.h
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "] -> x,y,w,h: " this.Dump() ; _DBG_
	}

	__debug(value="") { ; _DBG_
	/* ===============================================================================
	Method: __debug
	Set or get the debug flag
		
	Parameters:
	value - Value to set the debug flag to (*OPTIONAL*)

	Returns:
	true or false, depending on current value
	*/  
		if % (value="") ; _DBG_
			return this._debug ; _DBG_
		value := value<1?0:1 ; _DBG_
		this._debug := value ; _DBG_
		return this._debug ; _DBG_
	} ; _DBG_
	__Get(aName) {
		/* ---------------------------------------------------------------------------------------
		Property: x [get/set]
		Get or Set x-coordinate of the upper left corner of the rectangle
				
		This is identical to property <xul at #xul>
		*/
		
		/* ---------------------------------------------------------------------------------------
		Property: y [get/set]
		Get or Set y-coordinate of the upper left corner of the rectangle
				
		This is identical to property <yul at #yul>
		*/
		
		/* ---------------------------------------------------------------------------------------
		Property: w [get/set]
		Get or Set the width of the rectangle
		*/
		
		/* ---------------------------------------------------------------------------------------
		Property: h [get/set]
		Get or Set the height of the rectangle
		*/

        if (aName = "xul") ; x - upper left corner
		/* ---------------------------------------------------------------------------------------
		Property: xul [get/set]
		Get or Set x-coordinate of the upper left corner of the rectangle			
			
		This is identical to property <x at #x>
		*/
			return this.x
		if (aName = "yul") ; y - upper left corner
		/* ---------------------------------------------------------------------------------------
		Property: yul [get/set]
		Get or Set y-coordinate of the upper left corner of the rectangle			
				
		This is identical to property <y at #y>
		*/
			return this.y
		if (aName = "xlr") ; x - lower right corner
		/* ---------------------------------------------------------------------------------------
		Property: xlr [get/set]
		Get or Set x-coordinate of the lower right corner of the rectangle			
		*/
			return this.x+this.w
		if (aName = "ylr") ; y - lower right left corner
		/* ---------------------------------------------------------------------------------------
		Property: ylr [get/set]
		Get or Set y-coordinate of the lower right corner of the rectangle			
		*/
			return this.y+this.h
			
		return
	}
	__New(x=0, y=0, w=0, h=0, debug=false) {
	/*! ===============================================================================
	Method: __New
	Constructor (*INTERNAL*)

	Parameters:
	x,y,w,h - X,Y (upper left corner coordinates) and Width, Height of the rectangle
	debug - Flag to enable debugging (*Optional* - Default: false)
	*/     

		this._debug := debug ; _DBG_
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(x=" x ", y=" y ", w=" w ", h=" h ", _debug=" debug ")] (version: " this._version ")" ; _DBG_
		this.x := x
		this.y := y
		this.w := w
		this.h := h
	}
	__Set(aName, aValue) {
	/*! ===============================================================================
	Method: __Set
	Custom Setter Function (*INTERNAL*)
	*/    
        if aName in xul,yul,xlr,ylr
		{
            if (aName = "xul")
				this.x := aValue
			else if (aName = "yul")
				this.y := aValue
			else if (aName = "xlr")
				this.w := aValue - this.x
			else if (aName = "ylr")
				this.h := aValue - this.y
				
			return aValue
		}
	}
}

/*!
	End of class
*/

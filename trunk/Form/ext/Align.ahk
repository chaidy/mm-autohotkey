/*
  Function:	Align
 			Aligns controls inside the parent.
 
  Parameter:
 			hCtrl	- Control's handle or Parent handle. If other parameters are omitted, hCtrl represents Parent that
					  should be re-aligned. Use re-align when you hide/show/resize controls to reposition remaining controls.
 			Type	- String specifying align type. Available align types are Left, Right, Top, Bottom, Fill and N.
 					  Top and Bottom types are horizontal alignments while Left and Right are vertical. Fill type is both
 					  vertically and horizontally aligned.
 					  Control will be aligned to the edge of given type of its parent. For any given Type, control's
 					  x, y are ignored, w is ignored for vertical, h for horizontal alignment.
					  If you specify number as align type, it will be seen as handle of the control which serves as a marker and
					  hCtrl will be put on the same position as the given control.

 			Dim		- Dimension, optional. This is width for vertical and height for horizontal alignment type.
 					  If you omit dimension, controls current dimension will be used.
 
  Remarks:
			Parent window size must be set prior to calling this function. Function is not limitted to top level windows, it can align
			controls inside container controls.

			The order in which you register controls to be aligned is important. 

			In case you use resizable GUI and <Attach> function, Align will reset Attach for the parent that is re-aligned.

  Example:
	(start code)
 			Align(h1, "L", 100)	  ;Align this control to the left edge of its parent, set width to 100,
 			Align(h2, "T")		  ; then align this control to the top minus space taken from previous control, use its own height,
 			Align(h3, "F")		  ; then set this control to fill remaining space.
 		
 			Align(hGui)			  ;Re-align hGui
	(end code)

  About:
		o 1.01 by majkinetor
		o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
 */
Align(HCtrl, Type="", Dim=""){
	static 
	HCtrl += 0
	if (Type="") {	;realign
		hParent := HCtrl
		%hParent%rect := ""
		loop, parse, %hParent%, |
		{
			StringSplit, s, A_LoopField, %A_Space%
			HCtrl := s1, Type := s2, %Type% := true, Dim := ""
			gosub %A_ThisFunc%
		}
		return IsFunc(t:="Attach") ? %t%(hParent) : ""
	} else if Type is integer
	{
		ControlGetPos, x, y, w, h, , ahk_id %Type%
		ControlMove, , x, y, w, h, ahk_id %HCtrl%
		return
	}

 	hParent := DllCall("GetParent", "uint", HCtrl, "Uint")
	if !hParent or !hCtrl
		return A_ThisFunc "> Invalid handle.   Control: " hCtrl "  Parent: " hParent

 Align:
	if Type not in l,r,t,b,f
		 return A_ThisFunc "> Unknown type: " Type 
	else l:=r:=t:=b:=f:=0, %Type% := true

	if (%hParent%rect = "") {
		c1 := c2 := 0
		Win_Get(hParent, "Lwh", c3, c4)
	} else StringSplit, c, %hParent%rect, %A_Space%

	if !InStr(%hParent%, HCtrl)
		%hParent% .= (%hParent% != "" ? "|" : "") HCtrl " " Type

	ControlGet, style, Style, , , ahk_id %HCtrl%
	if !(style & 0x10000000)	;WS_VISIBLE
		return

	if (Dim = "") {
		ControlGetPos,,,DimH,DimV,,ahk_id %HCtrl%
		Dim := r || l ? DimH : DimV
	}

	  x := r		? c3-Dim : c1
	, y := b		? c4-Dim : c2
	, w := r || l	? Dim : c3-c1
	, h := t || b	? Dim : c4-c2
	
	DllCall("SetWindowPos", "uint", Hctrl, "uint", 0, "uint", x, "uint", y, "uint", w, "uint", h, "uint", 4)
	
	  c1 += l ? Dim : 0
	, c2 += t ? Dim : 0
	, c3 -= r ? Dim : 0
	, c4 -= b ? Dim : 0

	%hParent%rect := c1 " " c2 " " c3 " " c4
 return
}
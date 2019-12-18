(*
	Error message codes
*)
	Helper function to open System Preferences and summon the Displays tab
*)
	Helper function to get the buttons from System Preferences that control the reolution.
	This assumes that the display of interest is labeled "Built-in Retina Display".  Other 
	display configurations may require tweaks.
	
	Returns: a Radio Group of 5 buttons, where button 1 is the lowest resolution (biggest
	pixels) and button 5 is the densest resolution (smallest pixels).  This Radio Group
	requires UI Scripting ("System Events") to access it.
*)
	Get the current value of the display resolution.
	
	Returns: a number from 1 to 5 where 1 is the lowest resolution (biggest
	pixels) and 5 is the densest resolution (smallest pixels).
*)
	Sets the display resolution using a number from 1 to 5 where 1 is the lowest resolution (biggest
	pixels) and 5 is the densest resolution (smallest pixels).
*)
	Decreases the display resolution by one notch
*)
	Increases the display resolution by one notch
*)
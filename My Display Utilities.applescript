(*
	Helper function to open System Preferences and summon the Displays tab
*)

(* Load error constants *)
tell script "My Error Codes"
end tell

(*
	Demo to interactively change resolution
*)
repeat while true
	try
		set action to display dialog "Select a resolution change" buttons {"Cancel", "Decrease", "Increase"} default button "Increase"
	on error -128
		return
	end try
end repeat

to showDisplaysTab()
	tell application "System Preferences"
		launch
		set current pane to pane "com.apple.preference.displays"
		tell its pane "Displays"
			anchor "displaysDisplayTab"
		end tell
	end tell
end showDisplaysTab

(*
	Helper function to get the buttons from System Preferences that control the reolution.
	This assumes that the display of interest is labeled "Built-in Retina Display".  Other
	display configurations may require tweaks.

	Returns: a Radio Group of 5 buttons, where button 1 is the lowest resolution (biggest
	pixels) and button 5 is the densest resolution (smallest pixels).  This Radio Group
	requires UI Scripting ("System Events") to access it.
*)
on getRetinaResolutionRadioGroup()
	tell me to showDisplaysTab()
	delay 0.3
	tell application "System Events"
		tell process "System Preferences"
			tell window "Built-in Retina Display"
				tell tab group 1
					click radio button "Display"
					tell radio group 1
						click radio button "Scaled"
					end tell
					return radio group 1 of group 1
				end tell
			end tell
		end tell
	end tell
end getRetinaResolutionRadioGroup

(*
	Get the current value of the display resolution.

	Returns: a number from 1 to 5 where 1 is the lowest resolution (biggest
	pixels) and 5 is the densest resolution (smallest pixels).
*)
on getScreenResolution()
	set current_resolution_button to 0
	set rg to getRetinaResolutionRadioGroup()
	tell application "System Events"
		tell rg
			repeat with button_number from 1 to 5
				if value of radio button button_number is true then
					return button_number
				end if
			end repeat
		end tell
	end tell
	-- Expected selected button not found, throw an error
	error "Current resolution button to in range of 1-5" number ERR_UNKNOWN_RESOLUTION
end getScreenResolution

(*
	Sets the display resolution using a number from 1 to 5 where 1 is the lowest resolution (biggest
	pixels) and 5 is the densest resolution (smallest pixels).
*)
on setScreenResolution to new_value
	if new_value is less than 1 or new_value is greater than 5 then
		error "Invalid resolution request: must be in range of 1-5" number ERR_INVALID_RESOLUTION_REQUESTED
	end if
	set rg to getRetinaResolutionRadioGroup()
	tell application "System Events"
		tell rg to click radio button new_value
	end tell
end setScreenResolution

(*
	Decreases the display resolution by one notch
*)
on decreaseScreenResoultion()
	set current_resolution to getScreenResolution()
	try
		setScreenResolution to current_resolution - 1
	on error ERR_INVALID_RESOLUTION_REQUESTED
		error "You are at the minimum resolution already" number ERR_AT_MIN_RESOLUTION
	end try
end decreaseScreenResoultion

(*
	Increases the display resolution by one notch
*)
on increaseScreenResoultion()
	set current_resolution to getScreenResolution()
	--display dialog current_resolution
	try
		setScreenResolution to current_resolution + 1
	on error ERR_INVALID_RESOLUTION_REQUESTED
		error "You are at the maximum resolution already" number ERR_AT_MAX_RESOLUTION
	end try
end increaseScreenResoultion


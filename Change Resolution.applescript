--
--	Created by: Paul Waldo
--	Created on: 2019-12-27
--
--	Copyright © 2019 WaresWaldo, LLC, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

property displayLib : script "My Display Utilities"

repeat while true
	set current_resolution to displayLib's getScreenResolution()
	try
		display dialog ¬
			"Your current resolution is " & ¬
			current_resolution & ¬
			" of 5." & return & ¬
			"Select how you would like to change your display's resolution." buttons {"Quit", "Decrease", "Increase"} ¬
			cancel button ¬
			"Quit" default button ¬
			"Increase" with title "Change Resolution"
		set action to the button returned of the result
		if action is "Decrease" then
			displayLib's decreaseScreenResoultion()
		else if action is "Increase" then
			displayLib's increaseScreenResoultion()
		end if
	on error error_message number error_number
		if error_number is -128 then
			return
		else
			display alert error_message
		end if
	end try
end repeat

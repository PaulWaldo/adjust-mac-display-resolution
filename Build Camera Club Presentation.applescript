--
--	Build Camera Club Presentation
--	Created by: Paul Waldo
--	Created on: 2026-02-03
--
--	Copyright © 2026 Paul Waldo, All Rights Reserved
--
--	This script creates a Keynote presentation from member photo submissions
--	organized in folders by member name.

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- =========================================================================
-- MAIN SCRIPT
-- =========================================================================

try
	-- Step 1: Get user input
	set userInput to getUserInput()
	set programTitle to programTitle of userInput
	set monthYear to monthYear of userInput
	set photoDirectory to photoDirectory of userInput

	-- Step 2: Scan directory for members and photos
	set memberData to getMemberPhotos(photoDirectory)

	-- Step 3: Validate we found members and photos
	if (count of memberData) = 0 then
		abortWithError("No member folders found in directory:" & return & return & photoDirectory & return & return & "Please ensure the directory contains subfolders named after members.", "Directory Scan")
	end if

	-- Verify at least one member has photos
	set totalPhotoCount to 0
	repeat with memberRecord in memberData
		set totalPhotoCount to totalPhotoCount + (count of photos of memberRecord)
	end repeat

	if totalPhotoCount = 0 then
		abortWithError("No image files found in any member folders." & return & return & "Directory: " & photoDirectory & return & return & "Please ensure member folders contain image files.", "Image File Scan")
	end if

	-- Step 4: Sort members by last name
	set sortedMembers to sortMembersByLastName(memberData)

	-- Step 5: Create Keynote document
	set theDocument to createKeynoteDocument()

	-- Step 6: Build presentation
	buildPresentation(theDocument, programTitle, monthYear, sortedMembers)

	-- Success message
	display dialog "Presentation created successfully!" & return & return & ¬
		"Members: " & (count of sortedMembers) & return & ¬
		"Total slides: " & totalPhotoCount + (count of sortedMembers) + 1 & return & return & ¬
		"You can now save the presentation." buttons {"OK"} default button "OK" with title "Success"

on error errMsg number errNum
	if errNum is not -128 then
		-- Unexpected error
		abortWithError("Unexpected error occurred:" & return & return & errMsg & return & return & "Error code: " & errNum, "Script Execution")
	end if
	-- User canceled (-128) - just exit silently
end try

-- =========================================================================
-- HANDLER: Get User Input
-- =========================================================================

on getUserInput()
	try
		-- Get program title
		set titleDialog to display dialog "Enter the program title:" & return & ¬
			"(e.g., \"This Could Be A Christmas Card\")" ¬
			default answer "" buttons {"Cancel", "Continue"} ¬
			default button "Continue" cancel button "Cancel" ¬
			with title "Program Title"

		set programTitle to text returned of titleDialog

		if programTitle is "" then
			abortWithError("Program title cannot be empty.", "User Input")
		end if

		-- Get month and year with default
		set currentDate to current date
		set defaultMonthYear to getMonthName(month of currentDate) & " " & (year of currentDate)

		set dateDialog to display dialog "Enter the month and year:" & return & ¬
			"(e.g., \"January 2026\")" ¬
			default answer defaultMonthYear buttons {"Cancel", "Continue"} ¬
			default button "Continue" cancel button "Cancel" ¬
			with title "Program Date"

		set monthYear to text returned of dateDialog

		if monthYear is "" then
			abortWithError("Month and year cannot be empty.", "User Input")
		end if

		-- Get photo directory
		try
			set photoDirectory to choose folder with prompt "Select the folder containing member photo folders:"
		on error
			abortWithError("You must select a photo directory to continue.", "Directory Selection")
		end try

		return {programTitle:programTitle, monthYear:monthYear, photoDirectory:photoDirectory}

	on error errMsg number errNum
		if errNum is -128 then
			-- User canceled
			error number -128
		else
			abortWithError("Error getting user input:" & return & return & errMsg, "User Input")
		end if
	end try
end getUserInput

-- =========================================================================
-- HANDLER: Get Member Photos
-- =========================================================================

on getMemberPhotos(baseFolder)
	set memberList to {}
	set errorInfo to missing value

	try
		set folderPath to POSIX path of baseFolder
	on error errMsg
		abortWithError("Cannot convert folder path:" & return & return & (baseFolder as text) & return & return & errMsg, "Path Conversion")
	end try

	try
		tell application "System Events"
			set subfolders to folders of folder folderPath
		end tell
	on error errMsg
		abortWithError("Cannot access directory:" & return & return & folderPath & return & return & errMsg & return & return & "Please ensure you have permission to read this directory.", "Directory Access")
	end try

	-- Process each subfolder (member folder)
	repeat with memberFolder in subfolders
		set memberName to missing value
		set fileInfoList to {}

		-- Get file information from System Events
		tell application "System Events"
			try
				set memberName to name of memberFolder

				-- Skip hidden folders and special folders
				if memberName does not start with "." and memberName is not "Icon" then
					set allFiles to files of memberFolder

					-- Collect file names and paths
					repeat with aFile in allFiles
						set end of fileInfoList to {fileName:name of aFile, filePath:POSIX path of aFile}
					end repeat
				end if
			on error errMsg
				-- Store error info to handle outside System Events context
				set errorInfo to {errorMsg:errMsg, folderName:memberName}
			end try
		end tell

		-- Check if we had an error and abort outside System Events context
		if errorInfo is not missing value then
			abortWithError("Error accessing member folder:" & return & return & (folderName of errorInfo) & return & return & (errorMsg of errorInfo), "Member Folder Access")
		end if

		-- Process files outside System Events context
		if memberName is not missing value and (count of fileInfoList) > 0 then
			set imageFiles to {}

			-- Filter for image files
			repeat with fileInfo in fileInfoList
				if isImageFile(fileName of fileInfo) then
					set end of imageFiles to (filePath of fileInfo)
				end if
			end repeat

			-- Only add member if they have images
			if (count of imageFiles) > 0 then
				set end of memberList to {memberName:memberName, photos:imageFiles}
			end if
		end if
	end repeat

	return memberList
end getMemberPhotos

-- =========================================================================
-- HANDLER: Check if file is an image
-- =========================================================================

on isImageFile(fileName)
	set imageExtensions to {".jpg", ".jpeg", ".png", ".tif", ".tiff", ".heic", ".heif", ".gif", ".bmp"}
	set lowerFileName to lowercaseText(fileName)

	repeat with ext in imageExtensions
		if lowerFileName ends with ext then
			return true
		end if
	end repeat

	return false
end isImageFile

-- =========================================================================
-- HANDLER: Convert text to lowercase
-- =========================================================================

on lowercaseText(theText)
	set lowerChars to "abcdefghijklmnopqrstuvwxyz"
	set upperChars to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set resultText to ""

	repeat with i from 1 to length of theText
		set currentChar to character i of theText
		set charIndex to offset of currentChar in upperChars
		if charIndex > 0 then
			set resultText to resultText & character charIndex of lowerChars
		else
			set resultText to resultText & currentChar
		end if
	end repeat

	return resultText
end lowercaseText

-- =========================================================================
-- HANDLER: Sort Members by Last Name
-- =========================================================================

on sortMembersByLastName(memberList)
	try
		-- Create a list of records with sort keys
		set sortableList to {}

		repeat with memberRecord in memberList
			set memberName to memberName of memberRecord
			set nameInfo to parseMemberName(memberName)
			set lastName to lastName of nameInfo
			set firstName to firstName of nameInfo

			-- Create sort key: "LastName, FirstName"
			set sortKey to lastName & ", " & firstName

			set end of sortableList to {sortKey:sortKey, memberName:memberName, photos:photos of memberRecord, firstName:firstName, lastName:lastName}
		end repeat

		-- Simple bubble sort
		set listSize to count of sortableList
		repeat with i from 1 to listSize - 1
			repeat with j from 1 to listSize - i
				set item1 to item j of sortableList
				set item2 to item (j + 1) of sortableList

				if (sortKey of item1) > (sortKey of item2) then
					-- Swap items
					set temp to item j of sortableList
					set item j of sortableList to item2
					set item (j + 1) of sortableList to temp
				end if
			end repeat
		end repeat

		-- Build final sorted list with display names (First Last)
		set sortedList to {}
		repeat with sortedItem in sortableList
			set displayName to (firstName of sortedItem) & " " & (lastName of sortedItem)
			set end of sortedList to {memberName:displayName, photos:photos of sortedItem}
		end repeat

		return sortedList

	on error errMsg number errNum
		if errNum is not -128 then
			abortWithError("Error sorting members:" & return & return & errMsg, "Member Sorting")
		else
			error number -128
		end if
	end try
end sortMembersByLastName

-- =========================================================================
-- HANDLER: Parse Member Name
-- =========================================================================

on parseMemberName(folderName)
	try
		set AppleScript's text item delimiters to " "
		set nameWords to text items of folderName
		set AppleScript's text item delimiters to ""

		if (count of nameWords) = 0 then
			abortWithError("Invalid member folder name (empty):" & return & return & folderName, "Name Parsing")
		else if (count of nameWords) = 1 then
			-- Single name - use as both first and last
			return {firstName:item 1 of nameWords, lastName:item 1 of nameWords}
		else
			-- Multiple words - last word is last name, rest is first name
			set lastName to item -1 of nameWords
			set firstNameWords to items 1 thru -2 of nameWords
			set AppleScript's text item delimiters to " "
			set firstName to firstNameWords as string
			set AppleScript's text item delimiters to ""
			return {firstName:firstName, lastName:lastName}
		end if

	on error errMsg number errNum
		if errNum is not -128 then
			abortWithError("Error parsing member name:" & return & return & folderName & return & return & errMsg, "Name Parsing")
		else
			error number -128
		end if
	end try
end parseMemberName

-- =========================================================================
-- HANDLER: Create Keynote Document
-- =========================================================================

on createKeynoteDocument()
	try
		tell application "Keynote"
			try
				activate
			on error
				abortWithError("Cannot launch Keynote application." & return & return & "Please ensure Keynote is installed.", "Keynote Launch")
			end try

			-- Check if theme exists
			try
				set themeExists to exists (theme "RCC Presentation")
			on error
				set themeExists to false
			end try

			if not themeExists then
				abortWithError("The theme 'RCC Presentation' does not exist in Keynote." & return & return & "Please ensure the theme is installed before running this script.", "Theme Validation")
			end if

			-- Create document with specified dimensions and theme
			try
				set theDocument to make new document with properties {document theme:theme "RCC Presentation", height:1200, width:1920}
			on error errMsg
				abortWithError("Cannot create Keynote document:" & return & return & errMsg & return & return & "Check that the theme 'RCC Presentation' is properly installed.", "Document Creation")
			end try

			-- Delete the default slide if it exists
			try
				tell theDocument
					if (count of slides) > 0 then
						delete slide 1
					end if
				end tell
			on error
				-- Ignore error if no slide to delete
			end try

			return theDocument
		end tell

	on error errMsg number errNum
		if errNum is not -128 then
			abortWithError("Error creating Keynote document:" & return & return & errMsg, "Document Creation")
		else
			error number -128
		end if
	end try
end createKeynoteDocument

-- =========================================================================
-- HANDLER: Build Presentation
-- =========================================================================

on buildPresentation(theDocument, programTitle, monthYear, sortedMembers)
	-- Create title slide
	set errorInfo to createTitleSlide(theDocument, programTitle, monthYear)
	if errorInfo is not missing value then
		abortWithError("Error creating title slide:" & return & return & errorInfo, "Title Slide Creation")
	end if

	-- Create slides for each member
	repeat with memberRecord in sortedMembers
		set memberName to memberName of memberRecord
		set photoList to photos of memberRecord

		-- Create member name slide
		set errorInfo to createMemberSlide(theDocument, memberName)
		if errorInfo is not missing value then
			abortWithError("Error creating member slide:" & return & return & "Member: " & memberName & return & return & errorInfo, "Member Slide Creation")
		end if

		-- Create a slide for each photo
		repeat with photoPath in photoList
			-- Verify file exists
			tell application "System Events"
				if not (exists file photoPath) then
					abortWithError("Image file not found:" & return & return & photoPath, "Image File Access")
				end if
			end tell

			-- Create photo slide
			set errorInfo to createPhotoSlide(theDocument, photoPath)
			if errorInfo is not missing value then
				abortWithError("Error creating photo slide:" & return & return & "Photo: " & photoPath & return & return & errorInfo, "Photo Slide Creation")
			end if
		end repeat
	end repeat
end buildPresentation

-- =========================================================================
-- HANDLER: Create Title Slide
-- =========================================================================

on createTitleSlide(theDocument, programTitle, monthYear)
	try
		tell application "Keynote"
			tell theDocument
				-- Use "Title" master slide
				try
					set titleMaster to master slide "Title"
					set titleSlide to make new slide at beginning with properties {base slide:titleMaster}
				on error
					-- Fallback to default slide if "Title" master not found
					set titleSlide to make new slide at beginning
				end try

				set object text of default title item of titleSlide to programTitle
				set object text of default body item of titleSlide to monthYear & " Program"

				-- Delete any extra default slides that may have been created
				try
					set slideCount to count of slides
					if slideCount > 1 then
						-- Delete slides 2 through end (keep only the title slide)
						repeat with i from slideCount to 2 by -1
							delete slide i
						end repeat
					end if
				end try
			end tell
		end tell
		return missing value
	on error errMsg number errNum
		if errNum is -128 then
			error number -128
		else
			return errMsg & " (This may indicate a problem with the theme's master slide layout.)"
		end if
	end try
end createTitleSlide

-- =========================================================================
-- HANDLER: Create Member Name Slide
-- =========================================================================

on createMemberSlide(theDocument, memberName)
	try
		tell application "Keynote"
			tell theDocument
				-- Use "Section" master slide
				try
					set sectionMaster to master slide "Section"
					set memberSlide to make new slide at end with properties {base slide:sectionMaster}
				on error
					-- Fallback to default slide if "Section" master not found
					set memberSlide to make new slide at end
				end try

				-- Set the member name on the title
				set object text of default title item of memberSlide to memberName
			end tell
		end tell
		return missing value
	on error errMsg number errNum
		if errNum is -128 then
			error number -128
		else
			return errMsg & " (This may indicate a problem with the theme's master slide layout.)"
		end if
	end try
end createMemberSlide

-- =========================================================================
-- HANDLER: Create Photo Slide
-- =========================================================================

on createPhotoSlide(theDocument, photoPath)
	try
		-- Convert POSIX path to file reference
		set imageFile to POSIX file photoPath

		tell application "Keynote"
			tell theDocument
				-- Use "Photo" master slide
				try
					set photoMaster to master slide "Photo"
					set photoSlide to make new slide at end with properties {base slide:photoMaster}
				on error
					-- Fallback to default slide if "Photo" master not found
					set photoSlide to make new slide at end
				end try

				-- Delete any existing placeholder images on the slide
				tell photoSlide
					try
						set existingImages to every image
						repeat with img in existingImages
							delete img
						end repeat
					end try

					-- Add the actual photo and size it to fit the slide
					set newImage to make new image with properties {file:imageFile}

					-- Get the image's natural dimensions
					set imgWidth to width of newImage
					set imgHeight to height of newImage

					-- Calculate scaling to fit the slide (1920x1200) while maintaining aspect ratio
					set slideWidth to 1920
					set slideHeight to 1200

					set widthRatio to slideWidth / imgWidth
					set heightRatio to slideHeight / imgHeight

					-- Use the SMALLER ratio to ensure the entire image fits within the slide
					if widthRatio < heightRatio then
						set scaleRatio to widthRatio
					else
						set scaleRatio to heightRatio
					end if

					-- Calculate new dimensions
					set newWidth to imgWidth * scaleRatio
					set newHeight to imgHeight * scaleRatio

					-- Center the image on the slide
					set newX to (slideWidth - newWidth) / 2
					set newY to (slideHeight - newHeight) / 2

					-- Apply the new size and position
					set properties of newImage to {width:newWidth, height:newHeight, position:{newX, newY}}
				end tell
			end tell
		end tell
		return missing value
	on error errMsg number errNum
		if errNum is -128 then
			error number -128
		else
			return errMsg & " (The image file may be corrupted or in an unsupported format.)"
		end if
	end try
end createPhotoSlide

-- =========================================================================
-- HANDLER: Get Month Name
-- =========================================================================

on getMonthName(monthNumber)
	set monthNames to {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
	try
		return item (monthNumber as integer) of monthNames
	on error
		return "January" -- Fallback
	end try
end getMonthName

-- =========================================================================
-- HANDLER: Abort with Error
-- =========================================================================

on abortWithError(errorMessage, errorLocation)
	display alert "SCRIPT ABORTED" message ¬
		"Critical error in: " & errorLocation & return & return & ¬
		errorMessage & return & return & ¬
		"The script has been terminated." ¬
		buttons {"Quit"} default button "Quit" as critical
	error number -128
end abortWithError
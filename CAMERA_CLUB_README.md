# Camera Club Presentation Builder

An AppleScript to automatically create Keynote presentations from member photo submissions organized in folders.

## Features

- Creates a 1920x1200 Keynote presentation (projector size)
- Uses the "RCC Presentation" theme
- Automatically sorts members by last name
- Creates a title slide with program name and date
- Creates individual slides for each member's photos
- Images are automatically centered and scaled to fit

## Requirements

- macOS with Keynote installed
- The "RCC Presentation" theme installed in Keynote
- Member photos organized in folders by name

## Usage

### Method 1: Run from Terminal

```bash
osascript "Build Camera Club Presentation.applescript"
```

### Method 2: Run from Script Editor

1. Open `Build Camera Club Presentation.applescript` in Script Editor
2. Press ⌘R (or click the Run button)

### Method 3: Double-click (optional)

If you want to run it by double-clicking:

1. Open the file in Script Editor
2. File → Export
3. File Format: Application
4. Save as "Build Camera Club Presentation.app"
5. Double-click the app to run

## Photo Organization

Your photos should be organized like this:

```
Program Photos/
├── Bruce Ward/
│   ├── photo1.jpg
│   ├── photo2.jpg
│   └── photo3.jpg
├── David Benton/
│   ├── photo1.jpg
│   └── photo2.jpg
└── Steve McTeer/
    └── photo1.jpg
```

- Each member's photos must be in a subfolder named after them
- The script will sort members by last name (Ward before Benton)
- Supports: .jpg, .jpeg, .png, .tif, .tiff, .heic, .heif, .gif, .bmp

## What the Script Does

1. **Prompts for input:**
   - Program title (e.g., "This Could Be A Christmas Card")
   - Month and year (defaults to current month/year)
   - Photo directory location

2. **Scans the directory:**
   - Finds all member folders
   - Collects image files from each folder
   - Validates that images exist

3. **Sorts members:**
   - Extracts first and last names from folder names
   - Sorts alphabetically by last name

4. **Creates presentation:**
   - Title slide: Program name + date
   - For each member:
     - Name slide (First Last)
     - One slide per photo (centered, scaled to fit)

5. **Ready to save:**
   - Presentation is created but not saved
   - You can review and manually save when ready

## Error Handling

The script will **abort immediately** with a clear error message if:

- Theme "RCC Presentation" is not installed
- No member folders are found
- No image files are found
- Any file cannot be accessed
- Keynote cannot be launched
- Any other error occurs

No silent failures - you will always know exactly what went wrong.

## Example Run

```bash
$ osascript "Build Camera Club Presentation.applescript"
```

1. Dialog appears: "Enter the program title"
   → Enter: "Winter Landscapes"

2. Dialog appears: "Enter the month and year"
   → Default: "February 2026" (or edit as needed)

3. File picker appears: "Select the folder containing member photo folders"
   → Select: `/Users/paul/Dropbox/February Program Photos`

4. Script runs and creates presentation

5. Success dialog: "Presentation created successfully!"
   → Shows member count and total slides

6. Keynote opens with your new presentation ready to save

## Troubleshooting

### "Theme 'RCC Presentation' does not exist"
- Install the theme in Keynote before running the script

### "No member folders found"
- Check that you selected the correct directory
- Ensure member names are in subfolders, not loose files

### "No image files found"
- Verify member folders contain image files
- Check that images have supported extensions

### Script won't run
- Ensure System Settings → Privacy & Security → Automation allows Terminal (or Script Editor) to control Keynote

## Credits

Created by: Paul Waldo
Created on: 2026-02-03
Copyright © 2026 WaresWaldo, LLC, All Rights Reserved
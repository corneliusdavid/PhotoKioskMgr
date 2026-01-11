# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PhotoKiosk Manager is a cross-platform FireMonkey (FMX) application built with Delphi that generates HTML-based photo directory pages for church/community member lookup. The application supports two browsing modes:
- **FirstName View**: Alphabetical listing of individual people
- **LastName View**: Alphabetical listing of family units

The application is designed to run on Windows and macOS only, no mobile platforms will be supported at this time.

## Building the Project

This is a Delphi project and will be built manually in the IDE; there will be no build automation.

## Architecture

### Application Structure

The application uses a **modular frame-based architecture** powered by TFrameStand:
1. **Main Form** (`ufrmPhotoKioskMgrMain.pas`): Lightweight container with TabControl and TFrameStand component
2. **Frames** (`Frames.*.pas`): Self-contained UI modules for each major function
3. **Data Module** (`udmPhotoKiosk.pas`): Centralized database access using FireDAC components

### TFrameStand Architecture

**TFrameStand** (from https://github.com/andrea-magni/TFrameStand) is used to manage frame lifecycle and display. Benefits:
- **Modular Design**: Each screen is a separate TFrame unit, promoting code reusability
- **Clean Separation**: Business logic stays in frames, main form is just a container
- **Easy Navigation**: Frames can be shown/hidden with simple API calls
- **Lifecycle Management**: TFrameStand handles frame creation, display, and cleanup

**Frame Loading Pattern:**
```pascal
// In main form onCreate:
FFrameInfo := FrameStand1.New<TMyFrame>(ParentLayout);
FFrameInfo.Show();
```

### Key Components

#### Main Form (`TfrmPhotoKioskMgrMain`)
- **Five-tab interface** with layout containers for frames:
  - `tabList` → hosts `TFrameFamilyList`
  - `tabEditFamily` → hosts `TFrameFamilyEdit`
  - `tabEditPerson` → hosts `TFramePersonEdit`
  - `tabGenerate` → hosts `TFrameGenerate`
  - `tabConfigure` → hosts `TFrameConfigure`
- **TFrameStand Component**: Manages all frame instances
- **Tab Change Handler**: Shows appropriate frame when user switches tabs

#### Frames (All in `Frames.*.pas` units)

**TFrameFamilyList** (`Frames.FamilyList.pas`)
- ListView displaying all active families from `v_families_by_last_name` view
- Search/filter functionality
- Add/Edit/Delete/Refresh buttons
- Double-click to edit family

**TFrameFamilyEdit** (`Frames.FamilyEdit.pas`)
- Edit family details (last_name, display_name, phone, email, notes)
- Validation: Last Name is required
- Save/Cancel buttons
- Methods: `NewFamily()`, `EditFamily(FamilyID)`

**TFramePersonEdit** (`Frames.PersonEdit.pas`)
- Edit person details (first_name, middle_name, last_name, birth_year, photo)
- Family selection via ComboBox
- Is Parent checkbox
- Methods: `NewPerson(FamilyID)`, `EditPerson(PersonID)`

**TFrameGenerate** (`Frames.Generate.pas`)
- Moved from original main form Generate tab
- Generate FirstName/LastName HTML pages (currently stubs with TODO)
- Preview functionality
- Progress bar and output log

**TFrameConfigure** (`Frames.Configure.pas`)
- Moved from original main form Configure tab
- Path configuration (Photos, Templates, Output, Database)
- INI file management (`~/Documents/PhotoKiosk/PhotoKiosk.ini`)
- Database connection testing

#### Data Module (`TdmPhotoKiosk`)
- **FireDAC Connection**: SQLite database with WAL journaling mode
- **Pre-configured Queries**:
  - `qryFirstNameView`: Maps to `v_people_by_first_name` view
  - `qryLastNameView`: Maps to `v_families_by_last_name` view
  - `qryNavFirstNameLetters`: Navigation letter index for FirstName view
  - `qryNavLastNameLetters`: Navigation letter index for LastName view
  - `qryFamilyMembers`: Gets all members of a family (param: `family_id`)
  - `qryPersonPhotos`: Gets all photos for a person (param: `person_id`)
- **Auto-initialization**: Database creation script embedded in `ExecuteCreationScripts()` if database doesn't exist
- **Default Database Location**: `~/Documents/PhotoKiosk/PhotoKiosk.db`

### Database Schema

**Tables**:
- `families`: Family units (last_name, display_name, photo_filename, contact info)
- `people`: Individual members (linked to families via family_id, includes first_name, last_name, is_parent flag)
- `photos`: Photo metadata (filename, dimensions, thumbnail path)
- `person_photos`: Many-to-many link between people and photos

**Views**:
- `v_people_by_first_name`: Individual people sorted by first name (includes first_letter for navigation)
- `v_families_by_last_name`: Families sorted by last name with concatenated member names (includes first_letter)

**Key Fields**:
- `people.full_name`: Generated computed column concatenating first/middle/last names
- `first_letter`: Extracted first character for alphabetical navigation (computed in views)
- `is_active`: Soft delete flag on families and people

See `Database/photokiosk_schema.sql` for complete schema with indexes and triggers.

## Development Notes

### FireDAC Configuration
- The database connection uses these SQLite parameters:
  - `LockingMode=Normal`
  - `Synchronous=Normal`
  - `JournalMode=WAL` (Write-Ahead Logging for better concurrency)
  - `ForeignKeys=True` (Enforces referential integrity)

### Cross-Platform Paths
- Use `System.IOUtils.TPath` for all path operations
- Default paths use `TPath.GetDocumentsPath` which resolves to:
  - Windows: `C:\Users\<username>\Documents`
  - macOS: `/Users/<username>/Documents`

### TFrameStand Development Patterns

**Creating a New Frame:**
1. Create new unit: `Frames.MyNewFrame.pas`
2. Inherit from `TFrame`, not `TForm`
3. Add business logic in the frame unit itself
4. Access shared data via `udmPhotoKiosk` data module
5. Add frame to main form's `LoadFrames()` method

**Example Frame Structure:**
```pascal
unit Frames.MyNewFrame;

interface
uses
  FMX.Types, FMX.Controls, FMX.Forms, udmPhotoKiosk;

type
  TFrameMyNewFrame = class(TFrame)
    // UI components declared here
  private
    // Private methods and fields
  public
    constructor Create(AOwner: TComponent); override;
    // Public interface methods
  end;

implementation

constructor TFrameMyNewFrame.Create(AOwner: TComponent);
begin
  inherited;
  // Initialization code here
end;

end.
```

**Inter-Frame Communication:**
- **Shared Data Module**: Access `dmPhotoKiosk` directly from any frame
- **Tab Switching**: Use `MainTabs.ActiveTab := tabName` to navigate
- **Data Refresh**: Call frame's public methods (e.g., `FFamilyListInfo.Frame.LoadFamilies()`)
- **Future Enhancement**: Consider using `TMessageManager` for event-based communication

### Template Processing (Not Yet Implemented)
The generation methods in `TFrameGenerate` are currently stubs. When implementing:
1. Read HTML templates from `Templates` directory (path configured in `TFrameConfigure`)
2. Query database views (`v_people_by_first_name` or `v_families_by_last_name`)
3. Replace template placeholders with database values
4. Generate navigation index by letter (use `first_letter` field from views)
5. Write output HTML files to `Output` directory

### UI State Management (per frame)
- **TFrameGenerate**: `SetGeneratingState(Boolean)`, `UpdateProgress(Step, Percent)`, `LogOutput(Message)`
- **TFrameFamilyList**: `LoadFamilies()`, `FilterFamilies(SearchText)`
- **Edit Frames**: `NewXXX()`, `EditXXX(ID)`, validation before save

### Testing Database Connection
Use `dmPhotoKiosk.TestConnection` method (available in `TFrameConfigure`) which safely attempts to open the connection and returns success/failure.

## Common Issues

### Database Path on First Run
If database doesn't exist, the application auto-creates it using the embedded schema in `ExecuteCreationScripts()`. Ensure write permissions to Documents folder.

### FireDAC Driver Requirements
The application requires the SQLite driver to be available. On Windows, this is typically included with Delphi RAD Studio. For deployment to other platforms, ensure the appropriate SQLite libraries are included.

### DPI Awareness
The project is configured with `AppDPIAwarenessMode=PerMonitorV2` for Windows platforms to handle high-DPI displays correctly.

## Project Dependencies

**Delphi Version**: Developed with RAD Studio 12.3 (indicated by Project Version 20.3 in .dproj)

**Key Units**:
- FireDAC components (FireDAC.*)
- FMX framework (FMX.*)
- System.IOUtils for cross-platform file operations

**Third-Party Packages** (from .dproj Win64 configuration):
- FrameStandPackage (UI framework extension)
- Various standard Embarcadero packages (FireDAC, REST components, etc.)

Note: The Win32 configuration references additional packages (QRWRun290, SynEdit, Skia, etc.) that may not be needed for Win64/cross-platform builds.

## License

This project is licensed under GNU General Public License v3.0. See LICENSE file for full text.

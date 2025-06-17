# Localization Setup

## Directory Structure
The localization system follows this structure:
- `Localization/`: Main folder containing all localization files
  - `LocalizationManager.swift`: Core utility for managing localization
  - `en.lproj/`: English language resources
    - `Localizable.strings`: English localized strings

## Usage

1. Access localized strings using the extension:
```swift
let message = "hello_world".localized
```

2. Add new keys to the Localizable.strings files.

3. To add a new language:
   - Create a new folder: `Localization/[language_code].lproj/`
   - Add a `Localizable.strings` file with the same keys but translated values

## Integration Notes
- Ensure all `.lproj` directories and `Localizable.strings` files are added to the Xcode project
- Set development language in project settings if needed
- No external dependencies are required for this implementation

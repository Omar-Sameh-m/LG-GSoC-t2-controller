 .# Logo Feature Fixes Summary

## Issues Identified and Fixed

### 1. Missing KML Visibility Tags
**Problem:** The ScreenOverlay was missing essential tags to make it visible.
**Fix:** Added the following tags to the KML in `lib/data/kml_maker.dart`:
- `<visibility>1</visibility>` - Makes the overlay visible by default
- `<drawOrder>99</drawOrder>` - Ensures the overlay appears on top of other content
- `<open>1</open>` - Opens the folder/document by default

### 2. No Google Earth Refresh
**Problem:** After sending the KML, Google Earth wasn't being notified to refresh.
**Fix:** Added `refreshGoogleEarth()` method in `lib/data/ssh_service.dart` that sends a refresh command to `/tmp/query.txt`. This is now called automatically after sending or cleaning logos.

### 3. Positioning Issues
**Problem:** The overlay position might have been off-screen.
**Fix:** Adjusted the positioning coordinates:
- Changed `overlayXY` from `y="0"` to `y="1"` (top of screen)
- Changed `screenXY` from `y="0.725"` to `y="0.98"` (near top-left corner)

### 4. Logo Only on lg3 (Leftmost Screen)
**Requirement:** The logo should only appear on machine lg3, which is the leftmost screen.
**Implementation:** 
- `sendLogos()` sends only to slave 3 (lg3)
- `cleanLogos()` cleans only from slave 3 (lg3)
- `sendLogoFromUrl()` sends only to slave 3 (lg3)

## MOST GUARANTEED WAY - Direct SSH to lg3

The most reliable method to ensure the logo appears on lg3 is to connect **directly** to lg3 via SSH, bypassing the master-slave sync entirely.

### New Methods Added:

#### `sendLogoDirectToLg3(kmlContent, fileName)`
1. Opens a direct SSH connection to `lg3` (not through master)
2. Writes the KML file directly to lg3's `/var/www/html/`
3. Updates lg3's own `kmls.txt` to point to the local file
4. Sends refresh command directly to lg3's Google Earth
5. **Fallback:** If direct connection fails, falls back to master-slave method

#### `cleanLogoDirectFromLg3(fileName)`
1. Opens direct SSH connection to lg3
2. Removes logo entry from lg3's `kmls.txt`
3. Sends refresh command directly to lg3
4. **Fallback:** If direct connection fails, falls back to master-slave method

### Why This Is More Guaranteed:
- **No master-slave sync delays** - Direct connection eliminates sync issues
- **Local file serving** - lg3 serves the file from its own web server
- **Direct refresh** - Refresh command goes straight to lg3's Google Earth
- **Automatic fallback** - If direct connection fails, it automatically tries the master-slave method

## Files Modified

### 1. `lib/data/kml_maker.dart`
- Enhanced `screenOverlayImage()` method with visibility tags and better positioning

### 2. `lib/data/ssh_service.dart`
- Added `sendLogoDirectToLg3()` - MOST GUARANTEED direct SSH method
- Added `cleanLogoDirectFromLg3()` - MOST GUARANTEED direct clean method
- Added `sendLogoToAllSlaves()` method
- Added `refreshGoogleEarth()` method
- Added `cleanAllSlaveLogos()` method

### 3. `lib/logic/cubit/lg_cubit.dart`
- Updated `sendLogos()` to use `sendLogoDirectToLg3()` (MOST GUARANTEED)
- Updated `cleanLogos()` to use `cleanLogoDirectFromLg3()` (MOST GUARANTEED)
- Updated `sendLogoFromUrl()` to use `sendLogoToSlave(3, ...)`

## How It Works Now

1. When you click "Send LG Logo":
   - Creates a KML with proper visibility settings
   - **Opens direct SSH connection to lg3**
   - Writes KML file directly to lg3's webroot
   - Updates lg3's own kmls.txt with local URL
   - Sends refresh command directly to lg3's Google Earth
   - **If direct fails, falls back to master-slave method**

2. When you click "Clean Logos":
   - **Opens direct SSH connection to lg3**
   - Removes logo entry from lg3's kmls.txt
   - Sends refresh command directly to lg3
   - **If direct fails, falls back to master-slave method**

## Testing Tips

1. Make sure you're connected to the LG system before sending logos
2. The logo should appear ONLY on the leftmost screen (lg3)
3. Check the debug console for success messages:
   - **Direct method:** "Connected directly to lg3" → "Logo KML written directly to lg3"
   - **Fallback method:** "Falling back to master-slave method..."
4. If you see "Falling back..." message, it means direct connection failed but it's still trying the old method

## Requirements for Direct Connection to Work

For the most guaranteed direct method to work:
- Your device must be able to resolve `lg3` hostname (or use IP address)
- lg3 must have SSH server running on the same port as master
- Same username/password as master

## Alternative Logo URLs

If the default logo doesn't show, you can try these alternative URLs in `sendLogos()`:
- `https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png`
- Any direct image URL (PNG or JPG recommended)

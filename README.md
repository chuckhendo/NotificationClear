# NotificationClear
SIMBL bundle to add a "Clear All" button to Notification Center on OS X.

[![Build Status](https://img.shields.io/github/release/w0lfschild/NotificationClear.svg)](https://github.com/w0lfschild/NotificationClear/releases/latest)   
[![Build Status](https://img.shields.io/github/downloads/w0lfschild/NotificationClear/latest/total.svg)](https://github.com/w0lfschild/NotificationClear/archive/master.zip)

## Requirements
- OS X Yosemite 10.9 or above
- [SIMBL](http://www.culater.net/software/SIMBL/SIMBL.php)

## Installation
- Download current version from [releases](https://github.com/w0lfschild/NotificationClear/releases)
- Install [SIMBL](http://www.culater.net/software/SIMBL/SIMBL.php) if you have not already
- If you're on 10.11 follow these [Instructions](https://github.com/norio-nomura/EasySIMBL/issues/26#issuecomment-117028426) 
- Drag and drop the bundle file into /Library/Application Support/SIMBL/Plugins
- Open Terminal and run
 
        osascript -e 'tell application "NotificationCenter" to inject SIMBL into Snow Leopard'

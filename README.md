# Win11 Fullscreen GhostUI

Brings buttery-smooth, UWP-style auto-hiding taskbars and window controls to legacy fullscreen Win32 applications.

## Why This Exists
True fullscreen applications strip the native Windows UI. This AutoHotkey v2 script injects a custom, non-focus-stealing title bar and dynamically summons the native Windows 11 taskbar without minimizing your foreground software.

## Features

Smart Hover Triggers: Push your cursor to the bottom to summon the taskbar; push to the top to summon minimize/maximize/close controls.

DPI-Aware Ghost UI: Custom UI measures and anchors itself perfectly regardless of your Windows display scaling.

Flyout Grace Period: Includes a custom 400ms safety buffer to click system tray overflow menus without the taskbar instantly vanishing.

## Requirements

Windows 10, 11

AutoHotkey v2.0+

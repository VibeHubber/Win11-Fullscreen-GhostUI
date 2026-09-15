#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode("Mouse", "Screen")
SetTimer(CheckHover, 50) 

Global TaskbarSummoned := false
Global TopBarVisible := false
Global TargetHWND := 0
Global TopBarWidth := 120 
Global DismissTimer := 0 ; The stopwatch

; ---------------------------------------------------------
; Build the "Ghost UI" Titlebar
; ---------------------------------------------------------
TopBar := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000 -DPIScale")
TopBar.MarginX := 0
TopBar.MarginY := 0
TopBar.SetFont("s10 bold", "Consolas")

BtnMin := TopBar.Add("Button", "w40 h30", "_")
BtnMax := TopBar.Add("Button", "w40 h30 x+0", "☐")
BtnClose := TopBar.Add("Button", "w40 h30 x+0 cRed", "X")

BtnMin.OnEvent("Click", DoMinimize)
BtnMax.OnEvent("Click", DoMaximize)
BtnClose.OnEvent("Click", DoClose)

CheckHover() {
    Global TaskbarSummoned, TopBarVisible, TargetHWND, TopBar, TopBarWidth, DismissTimer
    MouseGetPos(&mX, &mY, &mWin)
    
    activeHwnd := WinExist("A")
    
    ; The Gatekeeper
    if (!IsFullscreen(activeHwnd) && !TaskbarSummoned && !TopBarVisible) {
        return
    }

    ; =========================================
    ; BOTTOM ZONE: Taskbar Summoning & Interaction
    ; =========================================
    if (mY >= A_ScreenHeight - 2) {
        DismissTimer := 0 ; Reset stopwatch if resting at the bottom
        if (!TaskbarSummoned) {
            if (mWin != TopBar.Hwnd)
                TargetHWND := activeHwnd
            
            Send("#t") 
            TaskbarSummoned := true
            Sleep(200) 
        }
    } 
    else if (mY < A_ScreenHeight - 70 && TaskbarSummoned) {
        if (!IsTaskbarFlyout(mWin)) {
            ; Mouse left the taskbar and isn't on a menu. Start the clock.
            if (DismissTimer == 0) {
                DismissTimer := A_TickCount 
            } 
            else if (A_TickCount - DismissTimer > 400) {
                ; 400ms grace period expired. Nuke the taskbar.
                Send("{Esc}")
                if (TargetHWND) {
                    try WinActivate(TargetHWND)
                }
                TaskbarSummoned := false
                DismissTimer := 0
                Sleep(200) 
            }
        } else {
            ; Mouse safely landed on a flyout menu. Cancel the timer.
            DismissTimer := 0
        }
    } 
    else {
        ; Inside the 70px taskbar zone, but not at the bottom edge. Safe zone.
        DismissTimer := 0 
    }

    ; =========================================
    ; TOP ZONE: Window Controls Summoning
    ; =========================================
    if (mY <= 1) {
        if (!TopBarVisible) {
            if (mWin != TopBar.Hwnd)
                TargetHWND := activeHwnd
            
            TopBar.Show("x" (A_ScreenWidth - TopBarWidth) " y0 NoActivate")
            TopBarVisible := true
        }
    }
    else if (mY > 45 && TopBarVisible) {
        TopBar.Hide()
        TopBarVisible := false
    }
}

; ---------------------------------------------------------
; Helper: Identifies Windows 11 Taskbar & System Tray Popups
; ---------------------------------------------------------
IsTaskbarFlyout(hwnd) {
    if !hwnd
        return false
    try {
        cls := WinGetClass(hwnd)
        if (cls = "NotifyIconOverflowWindow"      
         || cls = "TopLevelWindowForOverflow"     
         || cls = "XamlExplorerHostIslandWindow"  
         || cls = "Windows.UI.Core.CoreWindow"    
         || cls = "Shell_TrayWnd"                 
         || cls = "tooltips_class32") {           
            return true
        }
    }
    return false
}

; ---------------------------------------------------------
; Helper: Validates if a window takes up the whole screen
; ---------------------------------------------------------
IsFullscreen(hwnd) {
    if !hwnd 
        return false
    try {
        cls := WinGetClass(hwnd)
        if (cls = "WorkerW" || cls = "Progman" || cls = "Shell_TrayWnd")
            return false
        
        WinGetPos(&X, &Y, &W, &H, hwnd)
        return (W >= A_ScreenWidth && H >= A_ScreenHeight)
    } catch {
        return false
    }
}

; ---------------------------------------------------------
; Button Action Logic
; ---------------------------------------------------------
DoMinimize(*) {
    Global TargetHWND
    if (TargetHWND)
        try WinMinimize(TargetHWND)
}

DoMaximize(*) {
    Global TargetHWND
    if (TargetHWND) {
        if (WinGetMinMax(TargetHWND) == 1) {
            try WinRestore(TargetHWND)
        } else {
            try WinMaximize(TargetHWND)
        }
    }
}

DoClose(*) {
    Global TargetHWND
    if (TargetHWND)
        try WinClose(TargetHWND)
}
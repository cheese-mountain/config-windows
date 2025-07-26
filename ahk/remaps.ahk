#Requires AutoHotkey v2.0.2
#SingleInstance Force

; ~LWin Up::Return
SetCapsLockState "AlwaysOff"

; Send caret with one press
VKBA::Send "{^}{Space}"

; Send custom f key (toggles WT quake mode)
#Space::Send "{F13}"

; Scroll up/down with win + u/d
#u::Send "{WheelUp 15}"
#d::Send "{WheelDown 15}"

; Bind win + h/j/k/l to ←/↓/↑/→ 
#h::Send "{Left}"
#j::Send "{Down}"
#k::Send "{Up}"
#l::Send "{Right}"

; Komorebic config
Komorebic(cmd) {
    RunWait(Format("komorebic.exe {}", cmd), , "Hide")
}

; Bind alt tab to cycle stack
; #m::Komorebic("cycle-focus next")
Lwin & Tab::Komorebic("cycle-focus next")
; LAlt & Tab::Komorebic("cycle-focus next")

; Focus windows
!h::Komorebic("focus left")
!j::Komorebic("focus down")
!k::Komorebic("focus up")
!l::Komorebic("focus right")

; Move windows
!+h::Komorebic("move left")
!+j::Komorebic("move down")
!+k::Komorebic("move up")
!+l::Komorebic("move right")

; Workspaces

; Start on 2 (main)
Komorebic("focus-workspace 2")

state := Map()
state["current"] := 2
state["previous"] := 0
workspaces := []
keys := ["§", "1", "2", "3"] 
for n, key in keys {
    ; idx := n
    ; Hotkey("#" key, (*) => SwitchWorkspace(idx))
    ws := Map()
    ws["layout"] := "grid"
    workspaces.Push(ws)
}


SwitchTo(n) {
    if (n == state["current"]) {
        return
    }
    state["previous"] := state["current"]
    state["current"] := n
    Komorebic(Format("focus-workspace {}", n))
}

MoveTo(n) {
    if (n == state["current"]) {
        return
    }
    state["previous"] := state["current"]
    state["current"] := n
    Komorebic(Format("move-to-workspace {}", n))
}

; Toggle between grid, float & monocle
ToggleLayout() { 
    current := state["current"]
    if (!workspaces.Has(current)) {
        return
    }
    layout := workspaces[current]["layout"]
    ; layout := layout == "grid" ? "float" : layout == "float" ? "monocle" : "grid"
    ; if (layout == "float") {
    ;     Komorebic("toggle-float")
    ; } else if (layout == "monocle") {
    ;     Komorebic("toggle-float")
    ;     Komorebic("toggle-monocle")
    ; } else {
    ;     Komorebic("toggle-monocle")
    ; }
    ; workspaces[current]["layout"] := layout

    Komorebic("toggle-monocle")
    workspaces[current]["layout"] := layout == "grid" ? "monocle" : "grid"
}

ToggleClaude() {
    if (state["current"] == 4) {
        if WinExist("Claude") {
            WinHide("Claude")
        }
        SwitchTo(state["previous"])
    } else {
        if WinExist("Claude") {
            WinShow("Claude")
        }
        SwitchTo(4)
    }
}

#§::SwitchTo(0)
#1::SwitchTo(1)
#2::SwitchTo(2)
#3::SwitchTo(3)
#4::SwitchTo(4)

; Move windows across workspaces
#+§::MoveTo(0)
#+1::MoveTo(1)
#+2::MoveTo(2)
#+3::MoveTo(3)
#+4::MoveTo(4)

; Quake like toggle for claude app here
^Space::ToggleClaude()

!q::ToggleLayout()
!w::{
    if WinExist("A") {
        WinClose "A" 
    }
}

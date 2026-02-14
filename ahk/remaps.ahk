; Bind Alt + w to close current window
!w::{
    if WinExist("A") {
        WinClose "A" 
    }
}

; Send custom keys with ctrl/win + space
^Space::Send "{F14}"
#Space::Send "{F13}"

switchOrMoveTo(i) {
    if (GetKeyState("Shift")) {
        MoveCurrentWindowToDesktop(i)
    } else {
        switchDesktopByNumber(i)
    }
}
   
Alt & 1::switchOrMoveTo(1)
Alt & 2::switchOrMoveTo(2)
Alt & 3::switchOrMoveTo(3)
Alt & 4::switchOrMoveTo(4)
Alt & 5::switchOrMoveTo(5)
Alt & 6::switchOrMoveTo(6)
Alt & 7::switchOrMoveTo(7)
Alt & 8::switchOrMoveTo(8)
Alt & 9::switchOrMoveTo(9)

; Navigate virtual windows with caps 
^Space::switchDesktopToLastOpened()

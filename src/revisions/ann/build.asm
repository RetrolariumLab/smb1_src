; All Night Nippon Super Mario Bros.: the main program and its three overlay
; files assembled as one unit, each overlay in its own scope, so the overlays
; reach the main program by name

.include "main.asm"

.scope ann_supplemental_courses
    .include "supplemental_courses.asm"
.endscope

.scope ann_ending
    .include "ending.asm"
.endscope

.scope ann_hard_courses
    .include "hard_courses.asm"
.endscope

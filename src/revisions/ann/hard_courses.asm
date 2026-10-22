; All Night Nippon NSMDATA4: the hard courses

.p02

.segment "NSMDATA4"
.org $c296

.include "../../platforms/late_fds/ann/courses/hard/loader.asm"
.include "../../platforms/late_fds/ann/courses/hard/tables.asm"
.include "../../platforms/late_fds/ann/courses/hard/life_down.asm"

; Align the shared gameplay extensions with their supplemental-course addresses
    .res $ad, $ff

.include "../../platforms/late_fds/ann/gameplay/overlay.asm"

; Original disk alignment before the first extended course stream
    .res $b7, $ff

.include "../../platforms/late_fds/ann/courses/hard/enemy_streams.asm"
.include "../../platforms/late_fds/ann/courses/hard/area_streams.asm"

.reloc

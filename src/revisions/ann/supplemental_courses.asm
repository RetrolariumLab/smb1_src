; All Night Nippon NSMDATA2: the supplemental courses and gameplay extensions

.p02

.segment "NSMDATA2"
.org $c470

.include "../../platforms/late_fds/ann/gameplay/overlay.asm"

; Original disk alignment before the first course stream
    .res $b7, $ff

.include "../../platforms/late_fds/ann/courses/supplemental/enemy_streams.asm"
.include "../../platforms/late_fds/ann/courses/supplemental/area_streams.asm"
.include "../../platforms/late_fds/ann/courses/supplemental/guest_chr.asm"

; NSMDATA2 occupies the complete $C470-$D270 disk-file window
    .byte $ff

.reloc

; Super Mario Bros. 2 supplemental-courses payload
; Reconstructed from the pinned doppelganger ca65 listing

.segment "SM2DATA2"
.scope smb2_supplemental_courses
    .include "../../platforms/late_fds/smb2/system/hardware.inc"
    .org $c470
    .include "../../platforms/late_fds/smb2/overlays/supplemental_courses/course_bank.asm"
    .reloc
.endscope

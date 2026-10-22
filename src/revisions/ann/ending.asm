; All Night Nippon NSMDATA3: the ending and its audio engine

.include "../../platforms/late_fds/ann/audio/ram.inc"

.p02

.segment "NSMDATA3"
.org $c5d0

.include "../../platforms/late_fds/ann/ending/overlay.asm"

; Preserve the unused disk-file window before the alternate audio engine
    .res $30d, $ff

.include "../../platforms/late_fds/ann/audio/engine.asm"
.include "../../platforms/late_fds/ann/audio/fds.asm"
.include "../../platforms/late_fds/ann/audio/music.asm"
.include "../../platforms/late_fds/ann/audio/output.asm"

.reloc

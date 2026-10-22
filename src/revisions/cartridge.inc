; The parts of a cartridge image around the PRG: the iNES header, the CHR and,
; for PlayChoice-10, its instruction ROM (make split cuts the CHR and that ROM
; from the ROMs)

.segment "HEADER"
    .byte "NES", $1A  ; iNES magic
    .byte $02  ; two 16 KiB PRG-ROM banks
.if con_revision_profile = con_revision_profile_vs
    .byte $02  ; two 8 KiB CHR-ROM banks
    .byte $39  ; mapper 99 low nibble, four-screen, vertical mirroring
    .byte $60  ; mapper 99 high nibble
.else
    .byte $01  ; one 8 KiB CHR-ROM bank
    .byte $01  ; mapper 0, vertical mirroring
    .byte $00  ; upper mapper bits
.endif
    .byte $00, $00, $00, $00, $00, $00, $00, $00

.segment "CHR"
.if con_revision_profile = con_revision_profile_vs
    .incbin "platforms/vs_smb/chr.bin"
.else
    .incbin "chr/smb.chr"
.endif
.if con_revision_profile = con_revision_profile_pc10
    .incbin "revisions/pc10/platform.extra"
.endif

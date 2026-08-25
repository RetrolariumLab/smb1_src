; --------------------------------

; music header offsets

MusicHeaderData:
    .byte DeathMusHdr-MHD  ; event music
    .byte GameOverMusHdr-MHD
    .byte VictoryMusHdr-MHD
    .byte WinCastleMusHdr-MHD
    .byte GameOverMusHdr-MHD
    .byte EndOfLevelMusHdr-MHD
    .byte TimeRunningOutHdr-MHD
    .byte SilenceHdr-MHD

    .byte GroundLevelPart1Hdr-MHD  ; area music
    .byte WaterMusHdr-MHD
    .byte UndergroundMusHdr-MHD
    .byte CastleMusHdr-MHD
    .byte Star_CloudHdr-MHD
    .byte GroundLevelLeadInHdr-MHD
    .byte Star_CloudHdr-MHD
    .byte SilenceHdr-MHD

    .byte GroundLevelLeadInHdr-MHD  ; ground level music layout
    .byte GroundLevelPart1Hdr-MHD, GroundLevelPart1Hdr-MHD
    .byte GroundLevelPart2AHdr-MHD, GroundLevelPart2BHdr-MHD, GroundLevelPart2AHdr-MHD, GroundLevelPart2CHdr-MHD
    .byte GroundLevelPart2AHdr-MHD, GroundLevelPart2BHdr-MHD, GroundLevelPart2AHdr-MHD, GroundLevelPart2CHdr-MHD
    .byte GroundLevelPart3AHdr-MHD, GroundLevelPart3BHdr-MHD, GroundLevelPart3AHdr-MHD, GroundLevelLeadInHdr-MHD
    .byte GroundLevelPart1Hdr-MHD, GroundLevelPart1Hdr-MHD
    .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD
    .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD
    .byte GroundLevelPart3AHdr-MHD, GroundLevelPart3BHdr-MHD, GroundLevelPart3AHdr-MHD, GroundLevelLeadInHdr-MHD
    .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD

; music headers
; header format is as follows:
; 1 byte - length byte offset
; 2 bytes -  music data address
; 1 byte - triangle data offset
; 1 byte - square 1 data offset
; 1 byte - noise data offset (not used by secondary music)

TimeRunningOutHdr:
    .byte $08, <TimeRunOutMusData, >TimeRunOutMusData, $27, $18
Star_CloudHdr:
    .byte $20, <Star_CloudMData, >Star_CloudMData, $2e, $1a, $40
EndOfLevelMusHdr:
    .byte $20, <WinLevelMusData, >WinLevelMusData, $3d, $21
ResidualHeaderData:
    .byte $20, $c4, $fc, $3f, $1d
UndergroundMusHdr:
    .byte $18, <UndergroundMusData, >UndergroundMusData, $00, $00
SilenceHdr:
    .byte $08, <SilenceData, >SilenceData, $00
CastleMusHdr:
    .byte $00, <CastleMusData, >CastleMusData, $93, $62
VictoryMusHdr:
    .byte $10, <VictoryMusData, >VictoryMusData, $24, $14
GameOverMusHdr:
    .byte $18, <GameOverMusData, >GameOverMusData, $1e, $14
WaterMusHdr:
    .byte $08, <WaterMusData, >WaterMusData, $a0, $70, $68
WinCastleMusHdr:
    .byte $08, <EndOfCastleMusData, >EndOfCastleMusData, $4c, $24
GroundLevelPart1Hdr:
    .byte $18, <GroundM_P1Data, >GroundM_P1Data, $2d, $1c, $b8
GroundLevelPart2AHdr:
    .byte $18, <GroundM_P2AData, >GroundM_P2AData, $20, $12, $70
GroundLevelPart2BHdr:
    .byte $18, <GroundM_P2BData, >GroundM_P2BData, $1b, $10, $44
GroundLevelPart2CHdr:
    .byte $18, <GroundM_P2CData, >GroundM_P2CData, $11, $0a, $1c
GroundLevelPart3AHdr:
    .byte $18, <GroundM_P3AData, >GroundM_P3AData, $2d, $10, $58
GroundLevelPart3BHdr:
    .byte $18, <GroundM_P3BData, >GroundM_P3BData, $14, $0d, $3f
GroundLevelLeadInHdr:
    .byte $18, <GroundMLdInData, >GroundMLdInData, $15, $0d, $21
GroundLevelPart4AHdr:
    .byte $18, <GroundM_P4AData, >GroundM_P4AData, $18, $10, $7a
GroundLevelPart4BHdr:
    .byte $18, <GroundM_P4BData, >GroundM_P4BData, $19, $0f, $54
GroundLevelPart4CHdr:
    .byte $18, <GroundM_P4CData, >GroundM_P4CData, $1e, $12, $2b
DeathMusHdr:
    .byte $18, <DeathMusData, >DeathMusData, $1e, $0f, $2d

; --------------------------------

; MUSIC DATA
; square 2/triangle format
; d7 - length byte flag (0-note, 1-length)
; if d7 is set to 0 and d6-d0 is nonzero:
; d6-d0 - note offset in frequency look-up table (must be even)
; if d7 is set to 1:
; d6-d3 - unused
; d2-d0 - length offset in length look-up table
; value of $00 in square 2 data is used as null terminator, affects all sound channels
; value of $00 in triangle data causes routine to skip note

; square 1 format
; d7-d6, d0 - length offset in length look-up table (bit order is d0,d7,d6)
; d5-d1 - note offset in frequency look-up table
; value of $00 in square 1 data is flag alternate control reg data to be loaded

; noise format
; d7-d6, d0 - length offset in length look-up table (bit order is d0,d7,d6)
; d5-d4 - beat type (0 - rest, 1 - short, 2 - strong, 3 - long)
; d3-d1 - unused
; value of $00 in noise data is used as null terminator, affects only noise

; all music data is organized into sections (unless otherwise stated):
; square 2, square 1, triangle, noise

Star_CloudMData:
    .incbin "ju_prg.bin", $79b8, $049




GroundM_P1Data:
    .incbin "ju_prg.bin", $7a01, $01b

SilenceData:
    .incbin "ju_prg.bin", $7a1c, $02d



GroundM_P2AData:
    .incbin "ju_prg.bin", $7a49, $02c



GroundM_P2BData:
    .incbin "ju_prg.bin", $7a75, $028



GroundM_P2CData:
    .incbin "ju_prg.bin", $7a9d, $025




GroundM_P3AData:
    .incbin "ju_prg.bin", $7ac2, $019


GroundM_P3BData:
    .incbin "ju_prg.bin", $7adb, $01e


; triangle data used by both sections of third part

GroundMLdInData:
    .incbin "ju_prg.bin", $7af9, $02c



; noise data used by lead-in and third part sections

GroundM_P4AData:
    .incbin "ju_prg.bin", $7b25, $026



GroundM_P4BData:
    .incbin "ju_prg.bin", $7b4b, $027



DeathMusData:
    .byte $86, $04  ; death music share data with fourth part c of ground level music

GroundM_P4CData:
    .incbin "ju_prg.bin", $7b74, $030





; noise data used by fourth part sections

CastleMusData:
    .incbin "ju_prg.bin", $7ba4, $0a1



GameOverMusData:
    .incbin "ju_prg.bin", $7c45, $02d



TimeRunOutMusData:
    .incbin "ju_prg.bin", $7c72, $03e



WinLevelMusData:
    .incbin "ju_prg.bin", $7cb0, $061



; square 2 and triangle use the same data, square 1 is unused
UndergroundMusData:
    .incbin "ju_prg.bin", $7d11, $041

; noise data directly follows square 2 here unlike in other songs
WaterMusData:
    .incbin "ju_prg.bin", $7d52, $0ff




EndOfCastleMusData:
    .incbin "ju_prg.bin", $7e51, $077



VictoryMusData:
    .incbin "ju_prg.bin", $7ec8, $038



; unused space

FreqRegLookupTbl:
    .incbin "ju_prg.bin", $7f00, $066

MusicLengthLookupTbl:
    .incbin "ju_prg.bin", $7f66, $030

EndOfCastleMusicEnvData:
    .byte $98, $99, $9a, $9b

AreaMusicEnvData:
    .incbin "ju_prg.bin", $7f9a, $008

WaterEventMusEnvData:
    .incbin "ju_prg.bin", $7fa2, $010
    .byte $95, $95, $95, $96, $96, $96, $96, $96
    .byte $96, $96, $96, $96, $96, $96, $96, $96
    .incbin "ju_prg.bin", $7fc2, $008

BowserFlameEnvData:
    .incbin "ju_prg.bin", $7fca, $020

BrickShatterEnvData:
    .incbin "ju_prg.bin", $7fca, $010

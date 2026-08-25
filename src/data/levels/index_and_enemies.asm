; -------------------------------------------------------------------------------------

AreaDataOfsLoopback:
    .byte $12, $36, $0e, $0e, $0e, $32, $32, $32, $0a, $26, $40

; -------------------------------------------------------------------------------------

LoadAreaPointer:
    JSR FindAreaPointer  ; find it and store it here
    STA ram_area_pointer
GetAreaType:
    AND #%01100000  ; mask out all but d6 and d5
    ASL
    ROL
    ROL
    ROL  ; make %0xx00000 into %000000xx
    STA ram_area_type  ; save 2 MSB as area type
    RTS

FindAreaPointer:
    LDY ram_world_number  ; load offset from world variable
    LDA WorldAddrOffsets,y
    CLC  ; add area number used to find data
    ADC ram_area_number
    TAY
    LDA AreaAddrOffsets,y  ; from there we have our area pointer
    RTS

GetAreaDataAddrs:
    LDA ram_area_pointer  ; use 2 MSB for Y
    JSR GetAreaType
    TAY
    LDA ram_area_pointer  ; mask out all but 5 LSB
    AND #%00011111
    STA ram_area_addrs_l_offset  ; save as low offset
    LDA EnemyAddrHOffsets,y  ; load base value with 2 altered MSB,
    CLC  ; then add base value to 5 LSB, result
    ADC ram_area_addrs_l_offset  ; becomes offset for level data
    TAY
    LDA EnemyDataAddrLow,y  ; use offset to load pointer
    STA ram_enemy_data_low
    LDA EnemyDataAddrHigh,y
    STA ram_enemy_data_high
    LDY ram_area_type  ; use area type as offset
    LDA AreaDataHOffsets,y  ; do the same thing but with different base value
    CLC
    ADC ram_area_addrs_l_offset
    TAY
    LDA AreaDataAddrLow,y  ; use this offset to load another pointer
    STA ram_area_data_low
    LDA AreaDataAddrHigh,y
    STA ram_area_data_high
    LDY #$00  ; load first byte of header
    LDA (ram_area_data),y
    PHA  ; save it to the stack for now
    AND #%00000111  ; save 3 LSB for foreground scenery or bg color control
    CMP #$04
    BCC StoreFore
    STA ram_background_color_ctrl  ; if 4 or greater, save value here as bg color control
    LDA #$00
StoreFore:
    STA ram_foreground_scenery  ; if less, save value here as foreground scenery
    PLA  ; pull byte from stack and push it back
    PHA
    AND #%00111000  ; save player entrance control bits
    LSR  ; shift bits over to LSBs
    LSR
    LSR
    STA ram_player_entrance_ctrl  ; save value here as player entrance control
    PLA  ; pull byte again but do not push it back
    AND #%11000000  ; save 2 MSB for game timer setting
    CLC
    ROL  ; rotate bits over to LSBs
    ROL
    ROL
    STA ram_game_timer_setting  ; save value here as game timer setting
    INY
    LDA (ram_area_data),y  ; load second byte of header
    PHA  ; save to stack
    AND #%00001111  ; mask out all but lower nybble
    STA ram_terrain_control
    PLA  ; pull and push byte to copy it to A
    PHA
    AND #%00110000  ; save 2 MSB for background scenery type
    LSR
    LSR  ; shift bits to LSBs
    LSR
    LSR
    STA ram_background_scenery  ; save as background scenery
    PLA
    AND #%11000000
    CLC
    ROL  ; rotate bits over to LSBs
    ROL
    ROL
    CMP #%00000011  ; if set to 3, store here
    BNE StoreStyle  ; and nullify other value
    STA ram_cloud_type_override  ; otherwise store value in other place
    LDA #$00
StoreStyle:
    STA ram_area_style
    LDA ram_area_data_low  ; increment area data address by 2 bytes
    CLC
    ADC #$02
    STA ram_area_data_low
    LDA ram_area_data_high
    ADC #$00
    STA ram_area_data_high
    RTS

; -------------------------------------------------------------------------------------
; GAME LEVELS DATA

WorldAddrOffsets:
    .byte World1Areas-AreaAddrOffsets, World2Areas-AreaAddrOffsets
    .byte World3Areas-AreaAddrOffsets, World4Areas-AreaAddrOffsets
    .byte World5Areas-AreaAddrOffsets, World6Areas-AreaAddrOffsets
    .byte World7Areas-AreaAddrOffsets, World8Areas-AreaAddrOffsets

AreaAddrOffsets:
World1Areas:
    .byte $25, $29, $c0, $26, $60
World2Areas:
    .byte $28, $29, $01, $27, $62
World3Areas:
    .byte $24, $35, $20, $63
World4Areas:
    .byte $22, $29, $41, $2c, $61
World5Areas:
    .byte $2a, $31, $26, $62
World6Areas:
    .byte $2e, $23, $2d, $60
World7Areas:
    .byte $33, $29, $01, $27, $64
World8Areas:
    .byte $30, $32, $21, $65

; bonus area data offsets, included here for comparison purposes
; underground bonus area  - c2
; cloud area 1 (day)      - 2b
; cloud area 2 (night)    - 34
; water area (5-2/6-2)    - 00
; water area (8-4)        - 02
; warp zone area (4-2)    - 2f

EnemyAddrHOffsets:
    .byte $1f, $06, $1c, $00

EnemyDataAddrLow:
    .byte <E_CastleArea1, <E_CastleArea2, <E_CastleArea3, <E_CastleArea4, <E_CastleArea5, <E_CastleArea6
    .byte <E_GroundArea1, <E_GroundArea2, <E_GroundArea3, <E_GroundArea4, <E_GroundArea5, <E_GroundArea6
    .byte <E_GroundArea7, <E_GroundArea8, <E_GroundArea9, <E_GroundArea10, <E_GroundArea11, <E_GroundArea12
    .byte <E_GroundArea13, <E_GroundArea14, <E_GroundArea15, <E_GroundArea16, <E_GroundArea17, <E_GroundArea18
    .byte <E_GroundArea19, <E_GroundArea20, <E_GroundArea21, <E_GroundArea22, <E_UndergroundArea1
    .byte <E_UndergroundArea2, <E_UndergroundArea3, <E_WaterArea1, <E_WaterArea2, <E_WaterArea3

EnemyDataAddrHigh:
    .byte >E_CastleArea1, >E_CastleArea2, >E_CastleArea3, >E_CastleArea4, >E_CastleArea5, >E_CastleArea6
    .byte >E_GroundArea1, >E_GroundArea2, >E_GroundArea3, >E_GroundArea4, >E_GroundArea5, >E_GroundArea6
    .byte >E_GroundArea7, >E_GroundArea8, >E_GroundArea9, >E_GroundArea10, >E_GroundArea11, >E_GroundArea12
    .byte >E_GroundArea13, >E_GroundArea14, >E_GroundArea15, >E_GroundArea16, >E_GroundArea17, >E_GroundArea18
    .byte >E_GroundArea19, >E_GroundArea20, >E_GroundArea21, >E_GroundArea22, >E_UndergroundArea1
    .byte >E_UndergroundArea2, >E_UndergroundArea3, >E_WaterArea1, >E_WaterArea2, >E_WaterArea3

AreaDataHOffsets:
    .byte $00, $03, $19, $1c

AreaDataAddrLow:
    .byte <L_WaterArea1, <L_WaterArea2, <L_WaterArea3, <L_GroundArea1, <L_GroundArea2, <L_GroundArea3
    .byte <L_GroundArea4, <L_GroundArea5, <L_GroundArea6, <L_GroundArea7, <L_GroundArea8, <L_GroundArea9
    .byte <L_GroundArea10, <L_GroundArea11, <L_GroundArea12, <L_GroundArea13, <L_GroundArea14, <L_GroundArea15
    .byte <L_GroundArea16, <L_GroundArea17, <L_GroundArea18, <L_GroundArea19, <L_GroundArea20, <L_GroundArea21
    .byte <L_GroundArea22, <L_UndergroundArea1, <L_UndergroundArea2, <L_UndergroundArea3, <L_CastleArea1
    .byte <L_CastleArea2, <L_CastleArea3, <L_CastleArea4, <L_CastleArea5, <L_CastleArea6

AreaDataAddrHigh:
    .byte >L_WaterArea1, >L_WaterArea2, >L_WaterArea3, >L_GroundArea1, >L_GroundArea2, >L_GroundArea3
    .byte >L_GroundArea4, >L_GroundArea5, >L_GroundArea6, >L_GroundArea7, >L_GroundArea8, >L_GroundArea9
    .byte >L_GroundArea10, >L_GroundArea11, >L_GroundArea12, >L_GroundArea13, >L_GroundArea14, >L_GroundArea15
    .byte >L_GroundArea16, >L_GroundArea17, >L_GroundArea18, >L_GroundArea19, >L_GroundArea20, >L_GroundArea21
    .byte >L_GroundArea22, >L_UndergroundArea1, >L_UndergroundArea2, >L_UndergroundArea3, >L_CastleArea1
    .byte >L_CastleArea2, >L_CastleArea3, >L_CastleArea4, >L_CastleArea5, >L_CastleArea6

; ENEMY OBJECT DATA

; level 1-4/6-4
E_CastleArea1:
    .incbin "ju_prg.bin", $1d70, $027

; level 4-4
E_CastleArea2:
    .incbin "ju_prg.bin", $1d97, $019

; level 2-4/5-4
E_CastleArea3:
    .incbin "ju_prg.bin", $1db0, $02f

; level 3-4
E_CastleArea4:
    .incbin "ju_prg.bin", $1ddf, $02b

; level 7-4
E_CastleArea5:
    .incbin "ju_prg.bin", $1e0a, $015

; level 8-4
E_CastleArea6:
    .incbin "ju_prg.bin", $1e1f, $03a

; level 3-3
E_GroundArea1:
    .incbin "ju_prg.bin", $1e59, $025

; level 8-3
E_GroundArea2:
    .incbin "ju_prg.bin", $1e7e, $01d

; level 4-1
E_GroundArea3:
    .incbin "ju_prg.bin", $1e9b, $00e

; level 6-2
E_GroundArea4:
    .incbin "ju_prg.bin", $1ea9, $027

; level 3-1
E_GroundArea5:
    .incbin "ju_prg.bin", $1ed0, $031

; level 1-1
E_GroundArea6:
    .incbin "ju_prg.bin", $1f01, $01e

; level 1-3/5-3
E_GroundArea7:
    .incbin "ju_prg.bin", $1f1f, $01d

; level 2-3/7-3
E_GroundArea8:
    .incbin "ju_prg.bin", $1f3c, $015

; level 2-1
E_GroundArea9:
    .incbin "ju_prg.bin", $1f51, $02a
; end of data terminator here is also used by pipe intro area
E_GroundArea10:
    .byte $ff

; level 5-1
E_GroundArea11:
    .incbin "ju_prg.bin", $1f7c, $024

; cloud level used in levels 2-1 and 5-2
E_GroundArea12:
    .incbin "ju_prg.bin", $1fa0, $009

; level 4-3
E_GroundArea13:
    .incbin "ju_prg.bin", $1fa9, $025

; level 6-3
E_GroundArea14:
    .incbin "ju_prg.bin", $1fce, $023

; level 6-1
E_GroundArea15:
    .incbin "ju_prg.bin", $1ff1, $009

; warp zone area used in level 4-2
E_GroundArea16:
    .byte $ff

; level 8-1
E_GroundArea17:
    .incbin "ju_prg.bin", $1ffb, $03a

; level 5-2
E_GroundArea18:
    .incbin "ju_prg.bin", $2035, $02b

; level 8-2
E_GroundArea19:
    .incbin "ju_prg.bin", $2060, $02e

; level 7-1
E_GroundArea20:
    .incbin "ju_prg.bin", $208e, $01c

; cloud level used in levels 3-1 and 6-2
E_GroundArea21:
    .incbin "ju_prg.bin", $20aa, $009

; level 3-2
E_GroundArea22:
    .incbin "ju_prg.bin", $20b3, $025

; level 1-2
E_UndergroundArea1:
    .incbin "ju_prg.bin", $20d8, $02d

; level 4-2
E_UndergroundArea2:
    .incbin "ju_prg.bin", $2105, $02e

; underground bonus rooms area used in many levels
E_UndergroundArea3:
    .incbin "ju_prg.bin", $2133, $02d

; water area used in levels 5-2 and 6-2
E_WaterArea1:
    .incbin "ju_prg.bin", $2160, $011

; level 2-2/7-2
E_WaterArea2:
    .incbin "ju_prg.bin", $2171, $02a

; water area used in level 8-4
E_WaterArea3:
    .incbin "ju_prg.bin", $219b, $014

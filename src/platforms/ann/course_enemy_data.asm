; ANN PRIMARY COURSE ENEMY DATA

; Each labeled stream retains its packed game format and $FF terminator

; Castle 1
off_ann_enemy_castle_1:
    .incbin "NSMMAIN.bin", $6745, $01d

; Castle 2
off_ann_enemy_castle_2:
    .incbin "ju_prg.bin", $1d97, $019

; Castle 3
off_ann_enemy_castle_3:
    .incbin "NSMMAIN.bin", $677b, $023

; Castle 4
off_ann_enemy_castle_4:
    .incbin "NSMMAIN.bin", $679e, $029

; Overworld 1
off_ann_enemy_overworld_1:
    .incbin "NSMMAIN.bin", $67c7, $021

; Overworld 3
off_ann_enemy_overworld_3:
    .incbin "NSMMAIN.bin", $67e8, $010

; Overworld 5
off_ann_enemy_overworld_5:
    .incbin "ju_prg.bin", $1ed0, $031

; Overworld 6
off_ann_enemy_overworld_6:
    .incbin "ju_prg.bin", $1f01, $01e

; Overworld 7
off_ann_enemy_overworld_7:
    .incbin "NSMMAIN.bin", $6847, $019

; Overworld 8
off_ann_enemy_overworld_8:
    .byte $b8, $80, $0f, $03, $08, $0e
    .byte $ff

; Overworld 9
off_ann_enemy_overworld_9:
    .incbin "NSMMAIN.bin", $6867, $02f

; Overworld 12
off_ann_enemy_overworld_12:
    .byte $0a, $aa, $0e, $28, $2a
    .byte $ff

; Overworld 13
off_ann_enemy_overworld_13:
    .incbin "NSMMAIN.bin", $689c, $024
off_ann_enemy_overworld_16:
    .byte $ff

; Overworld 21
off_ann_enemy_overworld_21:
    .byte $0a, $aa, $0e, $24, $4a
    .byte $ff

; Overworld 22
off_ann_enemy_overworld_22:
    .incbin "NSMMAIN.bin", $68c7, $024
off_ann_enemy_overworld_22_end:
    .byte $ff

; Underground 1
off_ann_enemy_underground_1:
    .incbin "ju_prg.bin", $20d8, $02d

; Underground 2
off_ann_enemy_underground_2:
    .incbin "NSMMAIN.bin", $6919, $02e

; Underground 3
off_ann_enemy_underground_3:
    .incbin "NSMMAIN.bin", $6947, $01b

; Water 2
off_ann_enemy_water_2:
    .incbin "NSMMAIN.bin", $6962, $019

off_ann_enemy_data_end:

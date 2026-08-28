; ANN NSMDATA2 ENEMY STREAMS

; Streams retain the packed disk format and their original terminators

off_ann_data2_enemy_castle_4_smb2:
    .incbin "supplemental_course_enemy_streams.bin", $0000, $035

off_ann_data2_enemy_castle_2_smb2:
    .incbin "SM2MAIN.bin", $67af, $027

off_ann_data2_enemy_castle_5:
    .incbin "ju_prg.bin", $1e0a, $015

off_ann_data2_enemy_castle_8_smb2:
    .incbin "supplemental_course_enemy_streams.bin", $0071, $040

off_ann_data2_enemy_overworld_2:
    .incbin "ju_prg.bin", $1e7e, $01d

off_ann_data2_enemy_overworld_4:
    .incbin "supplemental_course_enemy_streams.bin", $00ce, $027

off_ann_data2_enemy_overworld_7_vs:
    .incbin "SM2MAIN.bin", $6965, $023

off_ann_data2_enemy_overworld_8_vs:
    .incbin "SM2DATA2.bin", $02bc, $01d

off_ann_data2_enemy_overworld_11:
    .incbin "supplemental_course_enemy_streams.bin", $0135, $024

off_ann_data2_enemy_overworld_26:
    .byte $0a, $aa, $0e, $31, $88, $ff

off_ann_data2_enemy_overworld_14:
    .incbin "supplemental_course_enemy_streams.bin", $015f, $023

off_ann_data2_enemy_overworld_15:
    .incbin "ju_prg.bin", $1ff1, $009

off_ann_data2_enemy_overworld_17:
    .incbin "supplemental_course_enemy_streams.bin", $018b, $03a

off_ann_data2_enemy_overworld_18:
    .incbin "supplemental_course_enemy_streams.bin", $01c5, $02b

off_ann_data2_enemy_overworld_19:
    .incbin "supplemental_course_enemy_streams.bin", $01f0, $030

off_ann_data2_enemy_overworld_20:
    .incbin "supplemental_course_enemy_streams.bin", $0220, $01c

off_ann_data2_enemy_overworld_27:
    .byte $0a, $aa, $1e, $23, $aa, $ff

off_ann_data2_enemy_underground_4:
    .incbin "supplemental_course_enemy_streams.bin", $0242, $019

off_ann_data2_enemy_water_1:
    .incbin "ju_prg.bin", $2160, $011

off_ann_data2_enemy_water_2_vs:
    .incbin "supplemental_course_enemy_streams.bin", $026c, $02e

off_ann_data2_enemy_water_4_smb2:
    .incbin "supplemental_course_enemy_streams.bin", $029a, $00e

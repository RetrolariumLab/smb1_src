; ANN NSMDATA2 AREA STREAMS

; Streams retain the packed disk format and their original terminators

off_ann_data2_area_castle_4_smb2:
    .incbin "supplemental_course_area_streams.bin", $0000, $075

off_ann_data2_area_castle_2_smb2:
    .incbin "supplemental_course_area_streams.bin", $0075, $08d

off_ann_data2_area_castle_5:
    .incbin "supplemental_course_area_streams.bin", $0102, $08b

off_ann_data2_area_castle_8_smb2:
    .incbin "supplemental_course_area_streams.bin", $018d, $0d3

off_ann_data2_area_overworld_2:
    .incbin "supplemental_course_area_streams.bin", $0260, $06d

off_ann_data2_area_overworld_4:
    .incbin "supplemental_course_area_streams.bin", $02cd, $091

off_ann_data2_area_overworld_7_vs:
    .incbin "supplemental_course_area_streams.bin", $035e, $049

off_ann_data2_area_overworld_8_vs:
    .incbin "supplemental_course_area_streams.bin", $03a7, $06d

off_ann_data2_area_overworld_11:
    .incbin "supplemental_course_area_streams.bin", $0414, $041

off_ann_data2_area_overworld_26:
    .incbin "ju_prg.bin", $287a, $015

off_ann_data2_area_overworld_14:
    .incbin "supplemental_course_area_streams.bin", $046a, $067

off_ann_data2_area_overworld_15:
    .incbin "supplemental_course_area_streams.bin", $04d1, $075

off_ann_data2_area_overworld_17:
    .incbin "supplemental_course_area_streams.bin", $0546, $095

off_ann_data2_area_overworld_18:
    .incbin "supplemental_course_area_streams.bin", $05db, $077

off_ann_data2_area_overworld_19:
    .incbin "supplemental_course_area_streams.bin", $0652, $07d

off_ann_data2_area_overworld_20:
    .incbin "supplemental_course_area_streams.bin", $06cf, $061

off_ann_data2_area_overworld_27:
    .incbin "ju_prg.bin", $2bd7, $02b

off_ann_data2_area_underground_4:
    .incbin "supplemental_course_area_streams.bin", $075b, $059

off_ann_data2_area_water_1:
    .incbin "supplemental_course_area_streams.bin", $07b4, $041

off_ann_data2_area_water_2_vs:
    .incbin "supplemental_course_area_streams.bin", $07f5, $0c9

off_ann_data2_area_water_4_smb2:
    .incbin "supplemental_course_area_streams.bin", $08be, $019

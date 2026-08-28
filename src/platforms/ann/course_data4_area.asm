; ANN NSMDATA4 AREA STREAMS

; Streams retain the packed disk format and their original terminators

off_ann_data4_area_castle_1:
    .incbin "extended_course_area_streams.bin", $0000, $073

off_ann_data4_area_castle_2:
    .incbin "extended_course_area_streams.bin", $0073, $07d

off_ann_data4_area_castle_3:
    .incbin "extended_course_area_streams.bin", $00f0, $093

off_ann_data4_area_castle_4:
    .incbin "extended_course_area_streams.bin", $0183, $08f

off_ann_data4_area_overworld_1:
    .incbin "extended_course_area_streams.bin", $0212, $089

off_ann_data4_area_overworld_2:
    .incbin "extended_course_area_streams.bin", $029b, $053

off_ann_data4_area_overworld_12_smb2:
    .incbin "extended_course_area_streams.bin", $02ee, $08b

off_ann_data4_area_overworld_7_smb2:
    .incbin "extended_course_area_streams.bin", $0379, $063

off_ann_data4_area_overworld_5:
    .incbin "extended_course_area_streams.bin", $03dc, $073

off_ann_data4_area_overworld_6:
    .incbin "extended_course_area_streams.bin", $044f, $05b

off_ann_data4_area_overworld_7:
    .incbin "extended_course_area_streams.bin", $04aa, $077

off_ann_data4_area_overworld_19_smb2:
    .incbin "extended_course_area_streams.bin", $0521, $06f

off_ann_data4_area_overworld_9:
    .incbin "extended_course_area_streams.bin", $0590, $04d

off_ann_data4_area_overworld_10:
    .incbin "extended_course_area_streams.bin", $05dd, $06f

off_ann_data4_area_overworld_11:
    .incbin "extended_course_area_streams.bin", $064c, $023

off_ann_data4_area_overworld_12:
    .incbin "SM2DATA4.bin", $0c36, $01d

off_ann_data4_area_underground_1:
    .incbin "extended_course_area_streams.bin", $068c, $075

off_ann_data4_area_underground_2:
    .incbin "extended_course_area_streams.bin", $0701, $05f

off_ann_data4_area_water_1:
    .incbin "extended_course_area_streams.bin", $0760, $079

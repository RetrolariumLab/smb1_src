off_smb2_main_castle_area_1_enemies:
    .incbin "programs/SM2MAIN.bin", $6790, $01f

; level 2-4
off_smb2_main_castle_area_2_enemies:
    .incbin "programs/SM2MAIN.bin", $67af, $027

; level 3-4
off_smb2_main_castle_area_3_enemies:
    .incbin "programs/SM2MAIN.bin", $67d6, $013

; level 4-4
off_smb2_main_castle_area_4_enemies:
    .incbin "programs/SM2MAIN.bin", $67e9, $035

; level 1-1
off_smb2_main_ground_area_1_enemies:
    .incbin "programs/SM2MAIN.bin", $681e, $026

; level 1-3
off_smb2_main_ground_area_2_enemies:
    .incbin "programs/SM2MAIN.bin", $6844, $023

; level 2-1
off_smb2_main_ground_area_3_enemies:
    .incbin "programs/SM2MAIN.bin", $6867, $029

; level 2-2
off_smb2_main_ground_area_4_enemies:
    .incbin "programs/SM2MAIN.bin", $6890, $036

; level 2-3
off_smb2_main_ground_area_5_enemies:
    .incbin "programs/SM2MAIN.bin", $68c6, $017

; level 3-1
off_smb2_main_ground_area_6_enemies:
    .incbin "programs/SM2MAIN.bin", $68dd, $02a

; level 3-3
off_smb2_main_ground_area_7_enemies:
    .incbin "programs/SM2MAIN.bin", $6907, $025

; level 4-1
off_smb2_main_ground_area_8_enemies:
    .incbin "programs/SM2MAIN.bin", $692c, $017

; level 4-2
off_smb2_main_ground_area_9_enemies:
    .incbin "programs/SM2MAIN.bin", $6943, $022

; level 4-3
off_smb2_main_ground_area_11_enemies:
    .incbin "programs/SM2MAIN.bin", $6965, $023

; cloud level used in levels 2-1, 3-1 and 4-1
off_smb2_main_ground_area_20_enemies:
    .incbin "programs/SM2MAIN.bin", $6988, $00c

; level 1-2
off_smb2_main_underground_area_1_enemies:
    .incbin "programs/SM2MAIN.bin", $6994, $026

; warp zone area used by level 1-2
off_smb2_main_underground_area_2_enemies:
    .incbin "programs/SM2MAIN.bin", $69ba, $00a

; underground bonus rooms used in many levels
off_smb2_main_underground_area_3_enemies:
    .incbin "programs/SM2MAIN.bin", $69c4, $01a

; level 3-2
off_smb2_main_water_area_1_enemies:
    .incbin "programs/SM2MAIN.bin", $69de, $026

; water area used by level 4-1
off_smb2_main_water_area_3_enemies:
    .incbin "programs/SM2MAIN.bin", $6a04, $010

; level 1-4
off_smb2_main_castle_area_1_objects:
    .incbin "programs/SM2MAIN.bin", $6a14, $05f

; level 2-4
off_smb2_main_castle_area_2_objects:
    .incbin "programs/SM2MAIN.bin", $6a73, $08b

; level 3-4
off_smb2_main_castle_area_3_objects:
    .incbin "programs/SM2MAIN.bin", $6afe, $097

; level 4-4
off_smb2_main_castle_area_4_objects:
    .incbin "programs/SM2MAIN.bin", $6b95, $075

; level 1-1
off_smb2_main_ground_area_1_objects:
    .incbin "programs/SM2MAIN.bin", $6c0a, $05b

; level 1-3
off_smb2_main_ground_area_2_objects:
    .incbin "programs/SM2MAIN.bin", $6c65, $04f

; level 2-1
off_smb2_main_ground_area_3_objects:
    .incbin "programs/SM2MAIN.bin", $6cb4, $079

; level 2-2
off_smb2_main_ground_area_4_objects:
    .incbin "programs/SM2MAIN.bin", $6d2d, $07d

; level 2-3
off_smb2_main_ground_area_5_objects:
    .incbin "programs/SM2MAIN.bin", $6daa, $05f

; level 3-1
off_smb2_main_ground_area_6_objects:
    .incbin "programs/SM2MAIN.bin", $6e09, $07f

; level 3-3
off_smb2_main_ground_area_7_objects:
    .incbin "programs/SM2MAIN.bin", $6e88, $05f

; level 4-1
off_smb2_main_ground_area_8_objects:
    .incbin "programs/SM2MAIN.bin", $6ee7, $077

; level 4-2
off_smb2_main_ground_area_9_objects:
    .incbin "programs/SM2MAIN.bin", $6f5e, $061

; level 4-3
off_smb2_main_ground_area_11_objects:
    .incbin "programs/SM2MAIN.bin", $6fbf, $049

; cloud level used in levels 2-1, 3-1 and 4-1
off_smb2_main_ground_area_20_objects:
    .incbin "programs/SM2MAIN.bin", $7008, $019

; level 1-2
off_smb2_main_underground_area_1_objects:
    .incbin "programs/SM2MAIN.bin", $7021, $0c1

; warp zone area used by level 1-2
off_smb2_main_underground_area_2_objects:
    .incbin "programs/SM2MAIN.bin", $70e2, $03b

; underground bonus rooms used with worlds 1-4
off_smb2_main_underground_area_3_objects:
    .incbin "programs/SM2MAIN.bin", $711d, $04b

; level 3-2
off_smb2_main_water_area_1_objects:
    .incbin "programs/SM2MAIN.bin", $7168, $0b3

; water area used by level 4-1
off_smb2_main_water_area_3_objects:
    .incbin "programs/SM2MAIN.bin", $721b, $031

; a bunch of unused space
    .res 83, $ff

; -------------------------------------------------------------------------------------

; this is overwritten by the contents of SM2SAVE
tbl_smb2_main_games_beaten_count:
    .byte $00

; -------------------------------------------------------------------------------------

off_smb2_data3_e_castle_area9:
    .incbin "SM2DATA3.bin", $04b0, $00a

; cloud level used in level 9-3
off_smb2_data3_e_castle_area10:
    .byte $1f, $01, $1e, $68, $06, $ff

; level 9-1 starting area
off_smb2_data3_e_ground_area25:
    .byte $1e, $05, $00, $ff

; two unused levels that have the same enemy data address as a used level
off_smb2_data3_e_ground_area26:
off_smb2_data3_e_ground_area27:

; level 9-1 water area
off_smb2_data3_e_water_area6:
    .incbin "SM2DATA3.bin", $04c4, $021

; level 9-2
off_smb2_data3_e_water_area7:
    .byte $1f, $01, $e6, $11, $ff

; level 9-4
off_smb2_data3_e_water_area8:
    .incbin "SM2DATA3.bin", $04ea, $011

; level 9-3
off_smb2_data3_l_castle_area9:
    .incbin "SM2DATA3.bin", $04fb, $063

; cloud level used by level 9-3
off_smb2_data3_l_castle_area10:
    .incbin "SM2DATA3.bin", $055e, $011

; level 9-1 starting area
off_smb2_data3_l_ground_area25:
    .incbin "SM2DATA3.bin", $056f, $00f

; two unused levels
off_smb2_data3_l_ground_area26:
    .byte $fd
off_smb2_data3_l_ground_area27:
    .byte $fd

; level 9-1 water area
off_smb2_data3_l_water_area6:
    .incbin "SM2DATA3.bin", $0580, $047

; level 9-2
off_smb2_data3_l_water_area7:
    .incbin "SM2DATA3.bin", $05c7, $043

; level 9-4
off_smb2_data3_l_water_area8:
    .incbin "SM2DATA3.bin", $060a, $05f

; -------------------------------------------------------------------------------------

; unused space

    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

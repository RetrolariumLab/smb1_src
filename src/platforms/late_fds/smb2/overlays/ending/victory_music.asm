tbl_smb2_data3_music_header_offset_data:
    .byte tbl_smb2_data3_victory_part_1a_header-MHD, tbl_smb2_data3_victory_part_1a_header-MHD, tbl_smb2_data3_victory_part_1b_header-MHD, tbl_smb2_data3_victory_part_1a_header-MHD
    .byte tbl_smb2_data3_victory_part_2a_header-MHD, tbl_smb2_data3_victory_part_2b_header-MHD, tbl_smb2_data3_victory_part_2a_header-MHD, tbl_smb2_data3_victory_part_2b_header-MHD
    .byte tbl_smb2_data3_victory_part_2c_header-MHD, tbl_smb2_data3_victory_part_2a_header-MHD, tbl_smb2_data3_victory_part_2d_header-MHD

; header format here is as follows:
; 1 byte - length byte offset
; 2 bytes - music data address
; 1 byte - triangle data offset
; 1 byte - square 1 data offset
; 1 byte - noise data offset
; these two are unique to the sound engine in this file
; 1 byte - FDS channel data offset
; 1 byte - waveform ID

off_smb2_data3_music_header_offsets:
tbl_smb2_data3_victory_part_1a_header:
    .byte $00, <off_smb2_data3_victory_m_p1_a_data, >off_smb2_data3_victory_m_p1_a_data, $3e, $14, $b0, $24, $01
tbl_smb2_data3_victory_part_1b_header:
    .byte $00, <off_smb2_data3_victory_m_p1_b_data, >off_smb2_data3_victory_m_p1_b_data, $50, $21, $61, $31, $02
tbl_smb2_data3_victory_part_2a_header:
    .byte $00, <off_smb2_data3_victory_m_p2_a_data, >off_smb2_data3_victory_m_p2_a_data, $43, $1c, $b5, $29, $01
tbl_smb2_data3_victory_part_2c_header:
    .byte $00, <off_smb2_data3_victory_m_p2_c_data, >off_smb2_data3_victory_m_p2_c_data, $50, $20, $61, $31, $02
tbl_smb2_data3_victory_part_2d_header:
    .byte $08, <off_smb2_data3_victory_m_p2_d_data, >off_smb2_data3_victory_m_p2_d_data, $09, $04, $1e, $06, $01
tbl_smb2_data3_victory_part_2b_header:
    .byte $08, <off_smb2_data3_victory_m_p2_b_data, >off_smb2_data3_victory_m_p2_b_data, $3a, $10, $9e, $28, $01

; residual data, probably from an old header
    .incbin "SM2DATA3.bin", $0a65, $003

; music data format here is the same as in sm2main file
; with a few exceptions: the value $00 does nothing special
; for square 1, and noise data format plays only one kind of
; beat for d5-d1 = nonzero, or rest for d5-d1 = 0

off_smb2_data3_victory_m_p1_a_data:
; square 2
    .incbin "SM2DATA3.bin", $0a68, $04f

off_smb2_data3_victory_m_p1_b_data:
; square 2
    .incbin "SM2DATA3.bin", $0ab7, $068

off_smb2_data3_victory_m_p2_a_data:
; square 2
    .incbin "SM2DATA3.bin", $0b1f, $017

off_smb2_data3_victory_m_p2_b_data:
; square 2
    .incbin "SM2DATA3.bin", $0b36, $03d

off_smb2_data3_victory_m_p2_c_data:
; square 2
    .incbin "SM2DATA3.bin", $0b73, $068

off_smb2_data3_victory_m_p2_d_data:
; square 2
    .incbin "SM2DATA3.bin", $0bdb, $025

off_smb2_data3_waveform_data2:
    .incbin "SM2DATA3.bin", $0c00, $020

off_smb2_data3_volume_envelope_data_2:
    .incbin "SM2DATA3.bin", $0c20, $004
off_smb2_data3_volume_envelope_data_1:
    .incbin "SM2DATA3.bin", $0c24, $00c

tbl_smb2_data3_fds_freq_lookup_tbl:
    .incbin "SM2DATA3.bin", $0c30, $03c

off_smb2_data3_victory_music_envelope_data:
    .incbin "SM2DATA3.bin", $0c6c, $010

; header format here is as follows:
; 2 bytes - waveform data address
; 1 byte  - master envelope timing (used with both volume envelope and sweep/modulation)
; 2 bytes - volume envelope data address
; 2 bytes - sweep envelope/mod frequency data address
; 1 byte  - modulation table data offset * 2

tbl_smb2_data3_waveform_header_offsets:
    .byte tbl_smb2_data3_waveform_1_header-tbl_smb2_data3_waveform_header_offsets, tbl_smb2_data3_waveform_2_header-tbl_smb2_data3_waveform_header_offsets

off_smb2_data3_waveform_header_data:
tbl_smb2_data3_waveform_1_header:
    .byte <off_smb2_data3_waveform_data1, >off_smb2_data3_waveform_data1, $44, <off_smb2_data3_volume_envelope_data_1
    .byte >off_smb2_data3_volume_envelope_data_1, <off_smb2_data3_sweep_mod_data1, >off_smb2_data3_sweep_mod_data1, (tbl_smb2_data3_mod_table2-tbl_smb2_data3_mod_table_data) * 2
tbl_smb2_data3_waveform_2_header:
    .byte <off_smb2_data3_waveform_data2, >off_smb2_data3_waveform_data2, $60, <off_smb2_data3_volume_envelope_data_2
    .byte >off_smb2_data3_volume_envelope_data_2, <off_smb2_data3_sweep_mod_data2, >off_smb2_data3_sweep_mod_data2, (tbl_smb2_data3_mod_table1-tbl_smb2_data3_mod_table_data) * 2
    .incbin "SM2DATA3.bin", $0c8e, $001

off_smb2_data3_waveform_data1:
    .incbin "SM2DATA3.bin", $0c8f, $020

off_smb2_data3_sweep_mod_data1:
    .incbin "SM2DATA3.bin", $0caf, $00a
off_smb2_data3_sweep_mod_data2:
    .incbin "SM2DATA3.bin", $0cb9, $006

tbl_smb2_data3_music_note_lengths:
    .incbin "SM2DATA3.bin", $0cbf, $010

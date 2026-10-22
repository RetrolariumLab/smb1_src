off_smb2_main_music_stream_star_cloud:
    .incbin "SM2MAIN.bin", $79ef, $049

off_smb2_main_music_stream_ground_part_1:
    .incbin "SM2MAIN.bin", $7a38, $01b

off_smb2_main_music_stream_silence:
    .incbin "SM2MAIN.bin", $7a53, $02d

off_smb2_main_music_stream_ground_part_2_a:
    .incbin "SM2MAIN.bin", $7a80, $02c

off_smb2_main_music_stream_ground_part_2_b:
    .incbin "SM2MAIN.bin", $7aac, $028

off_smb2_main_music_stream_ground_part_2_c:
    .incbin "SM2MAIN.bin", $7ad4, $025

off_smb2_main_music_stream_ground_part_3_a:
    .incbin "SM2MAIN.bin", $7af9, $019

off_smb2_main_music_stream_ground_part_3_b:
    .incbin "SM2MAIN.bin", $7b12, $01e

off_smb2_main_music_stream_ground_lead_in:
    .incbin "SM2MAIN.bin", $7b30, $02c

off_smb2_main_music_stream_ground_part_4_a:
    .incbin "SM2MAIN.bin", $7b5c, $026

off_smb2_main_music_stream_ground_part_4_b:
    .incbin "SM2MAIN.bin", $7b82, $027

off_smb2_main_music_stream_death:
    .incbin "SM2MAIN.bin", $7ba9, $002

off_smb2_main_music_stream_ground_part_4_c:
    .incbin "SM2MAIN.bin", $7bab, $030

off_smb2_main_music_stream_castle:
    .incbin "SM2MAIN.bin", $7bdb, $0a1

off_smb2_main_music_stream_game_over:
    .incbin "SM2MAIN.bin", $7c7c, $02d

off_smb2_main_music_stream_time_running_out:
    .incbin "SM2MAIN.bin", $7ca9, $03e

off_smb2_main_music_stream_end_of_level:
    .incbin "SM2MAIN.bin", $7ce7, $061

; square 2 and triangle use the same data, square 1 is unused
off_smb2_main_music_stream_underground:
    .incbin "SM2MAIN.bin", $7d48, $041

; noise data directly follows square 2 here unlike in other songs
off_smb2_main_music_stream_water:
    .incbin "SM2MAIN.bin", $7d89, $0ff

off_smb2_main_music_stream_castle_clear:
    .incbin "SM2MAIN.bin", $7e88, $078

tbl_smb2_main_music_note_periods:
    .incbin "SM2MAIN.bin", $7f00, $066

tbl_smb2_main_music_note_lengths:
    .incbin "SM2MAIN.bin", $7f66, $030

off_smb2_main_castle_clear_music_envelope:
    .incbin "SM2MAIN.bin", $7f96, $004

off_smb2_main_area_music_envelope_values:
    .incbin "SM2MAIN.bin", $7f9a, $008

off_smb2_main_water_and_event_music_envelope_values:
    .incbin "SM2MAIN.bin", $7fa2, $028

off_smb2_main_bowser_flame_volume_envelope:
    .incbin "SM2MAIN.bin", $7fca, $020

off_smb2_main_brick_shatter_volume_envelope:
    .incbin "SM2MAIN.bin", $7fea, $010

    .word handler_smb2_main_nmi_handler
    .word handler_smb2_main_reset_handler
    .word handler_smb2_main_irq_handler

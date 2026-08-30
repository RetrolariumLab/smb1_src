off_smb2_main_music_stream_star_cloud:
    .incbin "ju_prg.bin", $79b8, $049




off_smb2_main_music_stream_ground_part_1:
    .incbin "ju_prg.bin", $7a01, $01b

off_smb2_main_music_stream_silence:
    .incbin "ju_prg.bin", $7a1c, $02d



off_smb2_main_music_stream_ground_part_2_a:
    .incbin "ju_prg.bin", $7a49, $02c



off_smb2_main_music_stream_ground_part_2_b:
    .incbin "ju_prg.bin", $7a75, $028



off_smb2_main_music_stream_ground_part_2_c:
    .incbin "ju_prg.bin", $7a9d, $025




off_smb2_main_music_stream_ground_part_3_a:
    .incbin "ju_prg.bin", $7ac2, $019


off_smb2_main_music_stream_ground_part_3_b:
    .incbin "ju_prg.bin", $7adb, $01e


; triangle data used by both sections of third part

off_smb2_main_music_stream_ground_lead_in:
    .incbin "ju_prg.bin", $7af9, $02c



; noise data used by lead-in and third part sections

off_smb2_main_music_stream_ground_part_4_a:
    .incbin "ju_prg.bin", $7b25, $026



off_smb2_main_music_stream_ground_part_4_b:
    .incbin "ju_prg.bin", $7b4b, $027



off_smb2_main_music_stream_death:
    .byte $86, $04  ; death music share data with fourth part c of ground level music

off_smb2_main_music_stream_ground_part_4_c:
    .incbin "ju_prg.bin", $7b74, $030





; noise data used by fourth part sections

off_smb2_main_music_stream_castle:
    .incbin "ju_prg.bin", $7ba4, $0a1



off_smb2_main_music_stream_game_over:
    .incbin "ju_prg.bin", $7c45, $02d



off_smb2_main_music_stream_time_running_out:
    .incbin "ju_prg.bin", $7c72, $03e



off_smb2_main_music_stream_end_of_level:
    .incbin "ju_prg.bin", $7cb0, $061



; square 2 and triangle use the same data, square 1 is unused
off_smb2_main_music_stream_underground:
    .incbin "ju_prg.bin", $7d11, $041

; noise data directly follows square 2 here unlike in other songs
off_smb2_main_music_stream_water:
    .incbin "ju_prg.bin", $7d52, $0ff




off_smb2_main_music_stream_castle_clear:
    .incbin "SM2MAIN.bin", $7e88, $078



; unused byte

tbl_smb2_main_music_note_periods:
    .incbin "ju_prg.bin", $7f00, $066

tbl_smb2_main_music_note_lengths:
    .incbin "ju_prg.bin", $7f66, $030

off_smb2_main_castle_clear_music_envelope:
    .byte $98, $99, $9a, $9b

off_smb2_main_area_music_envelope_values:
    .incbin "ju_prg.bin", $7f9a, $008

off_smb2_main_water_and_event_music_envelope_values:
    .incbin "ju_prg.bin", $7fa2, $010
    .byte $95, $95, $95, $96, $96, $96, $96, $96
    .byte $96, $96, $96, $96, $96, $96, $96, $96
    .incbin "ju_prg.bin", $7fc2, $008

off_smb2_main_bowser_flame_volume_envelope:
    .incbin "ju_prg.bin", $7fca, $020

off_smb2_main_brick_shatter_volume_envelope:
    .incbin "ju_prg.bin", $7fca, $010

    .word handler_smb2_main_nmi_handler
    .word handler_smb2_main_reset_handler
    .word handler_smb2_main_irq_handler

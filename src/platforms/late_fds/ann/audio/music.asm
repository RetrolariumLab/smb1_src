; All Night Nippon FDS music streams and synthesis tables

tbl_ann_fds_music_offsets:
    .incbin "programs/NSMDATA3.bin", $0a2a, $00b

tbl_ann_fds_music_offsets_end:
    .incbin "programs/NSMDATA3.bin", $0a35, $033

tbl_ann_fds_song_a:
    .incbin "programs/NSMDATA3.bin", $0a68, $0b7

tbl_ann_fds_song_b:
    .incbin "programs/NSMDATA3.bin", $0b1f, $0bc

tbl_ann_fds_song_c:
    .incbin "programs/NSMDATA3.bin", $0bdb, $025

tbl_ann_fds_wave_b_data:
    .incbin "programs/NSMDATA3.bin", $0c00, $020

tbl_ann_fds_wave_b_volumes:
    .incbin "programs/NSMDATA3.bin", $0c20, $004

tbl_ann_fds_wave_a_volumes:
    .incbin "programs/NSMDATA3.bin", $0c24, $00c

tbl_ann_fds_wave_notes:
    .incbin "programs/NSMDATA3.bin", $0c30, $03c

tbl_ann_fds_envelope:
    .incbin "programs/NSMDATA3.bin", $0c6c, $010

tbl_ann_fds_wave_offsets:
    .incbin "programs/NSMDATA3.bin", $0c7c, $043

tbl_ann_fds_note_lengths:
    .incbin "programs/NSMDATA3.bin", $0cbf, $010

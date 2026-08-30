off_smb2_main_player_name_data:
    .incbin "NSMMAIN.bin", $65a6, $00a

off_smb2_main_player_palette_data:
    .incbin "ju_prg.bin", $05d7, $008

tbl_smb2_main_player_name_offsets:
    .byte $04, $09  ; note that offsets point to last byte

sub_smb2_main_patch_player_name_pal:
    LDY SelectedPlayer  ; get offset based on selected player
    LDA tbl_smb2_main_player_name_offsets,y
    PHA
    INY
    STY $00  ; save player + 1 temporarily (mario = 1, luigi = 2)
    TAY
    LDX #$04
bra_smb2_main_name_patch:
    LDA off_smb2_main_player_name_data,y  ; get name of selected player
    STA tbl_smb2_main_top_status_bar_packet+3,x  ; patch to top status bar and victory message
    STA off_smb2_main_thank_you_message+$d,x
    DEY
    DEX
    BPL bra_smb2_main_name_patch
    PLA  ; subtract player + 1 from offset loaded earlier
    SEC  ; to get proper offset for palette loading
    SBC $00
    TAY
    LDX #$03
bra_smb2_main_pal_patch:
    LDA off_smb2_main_player_palette_data,y  ; overwrite palette with the appropriate one
    STA tbl_smb2_main_player_palette_colors,x
    DEY
    DEX
    BPL bra_smb2_main_pal_patch
    RTS

; -------------------------------------------------------------------------------------

off_smb2_main_title_screen_gfx_data:
    .incbin "SM2MAIN.bin", $662b, $165

; -------------------------------------------------------------------------------------

; GAME LEVELS DATA

; level 1-4

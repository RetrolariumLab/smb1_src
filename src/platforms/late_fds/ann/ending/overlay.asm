; All Night Nippon ending sequence, guest procession, and ending text

handler_ann_ending_background:
    LDA ram_screen_routine_task
    JSR sub_dispatch_inline_handler
    .word handler_initialize_screen_step
    .word handler_write_top_status_line
    .word handler_write_bottom_status_line
    .word handler_ann_show_throne_room
    .word handler_select_area_palette
    .word handler_prepare_background_and_player_colors
    .word handler_ann_load_ending_palette
    .word handler_ann_show_princess

handler_ann_show_throne_room:
    LDA #$1b
    STA ram_vram_buffer_addr_ctrl
    STA ram_sprite0_hit_detect_flag

loc_ann_advance_ending_background:
    INC ram_screen_routine_task
    RTS

handler_ann_load_ending_palette:
    LDA #$1e
    STA ram_vram_buffer_addr_ctrl
    INC ram_screen_routine_task
    RTS

handler_ann_show_princess:
    LDA #$a2
    JSR sub_print_status_bar_numbers
    LDA #$cc
    STA off_ann_nmi_sound_handler_high
    LDA #$b1
    STA off_ann_nmi_sound_handler_low
    LDA #$01
    STA ram_area_music_queue
    LDA #$00
    STA ram_left_right_buttons
    STA ram_fds_background_pattern_bits
    STA ram_sprite0_hit_detect_flag
    STA ram_disable_screen_flag

loc_ann_advance_ending_state:
    INC ram_oper_mode_task
    RTS

handler_ann_ending_victory_message:
    LDA ram_secondary_msg_counter
    BNE $c63d
    LDY ram_primary_msg_counter
    CPY #$0a
    BCS $c64f
    INY
    INY
    INY
    CPY #$05
    BNE $c636
    LDA #$04
    STA ram_event_music_queue
    TYA
    CLC
    ADC #$0c
    STA ram_vram_buffer_addr_ctrl
    LDA ram_secondary_msg_counter
    CLC
    ADC #$04
    STA ram_secondary_msg_counter
    LDA ram_primary_msg_counter
    ADC #$00
    STA ram_primary_msg_counter
    RTS
    LDA #$0c
    STA ram_world_end_timer

loc_ann_initialize_ending_state:
    INC ram_oper_mode_task

sub_ann_clear_ending_state:
    LDA #$00
    STA ram_offscreen_player_info
    STA ram_off_scr_halfway_page
    STA ram_off_scr_level_number
    RTS

handler_ann_convert_extra_lives:
    LDA ram_world_end_timer
    BNE $c662
    LDA ram_onscreen_player_info
    BMI loc_ann_initialize_ending_state
    LDA ram_select_timer
    BNE $c662
    LDA #$30
    STA ram_select_timer
    LDA #$40
    STA ram_square2_sound_queue
    DEC ram_onscreen_player_info
    LDA #$01
    STA $0135
    JSR sub_ann_award_end_area_points
    LDA ram_ann_fds_music_current
    BNE $c68f
    LDA #$01
    STA ram_area_music_queue
    RTS

tbl_ann_ending_palette:
    .incbin "NSMDATA3.bin", $00c0, $003

tbl_ann_ending_palette_bytes:
    .incbin "NSMDATA3.bin", $00c3, $010

tbl_ann_ending_palette_bytes_end:
    .incbin "NSMDATA3.bin", $00d3, $001

tbl_ann_ending_palette_variants:
    .incbin "NSMDATA3.bin", $00d4, $004

tbl_ann_ending_lives_display:
    .incbin "NSMDATA3.bin", $00d8, $009

handler_ann_cycle_ending_palette:
    INC ram_offscreen_player_info
    LDA ram_off_scr_level_number
    BNE $c6c6
    LDA ram_offscreen_player_info
    AND #$ff
    BNE $c6f6
    INC ram_off_scr_level_number
    JMP $c6cd
    LDA ram_offscreen_player_info
    AND #$0f
    BNE $c6f6
    LDX #$13
    LDA tbl_ann_ending_palette, X
    STA ram_vram_buffer1, X
    DEX
    BPL $c6cf
    LDX #$0c
    LDY ram_off_scr_halfway_page
    LDA tbl_ann_ending_palette_variants, Y
    STA $0304, X
    DEX
    DEX
    DEX
    DEX
    BPL $c6dd
    INC ram_off_scr_halfway_page
    LDA ram_off_scr_halfway_page
    CMP #$04
    BNE $c6f6
    INC ram_oper_mode_task
    RTS

handler_ann_draw_ending_lives:
    LDX #$08
    LDA tbl_ann_ending_lives_display, X
    STA ram_vram_buffer1, X
    DEX
    BPL $c6f9
    INC ram_oper_mode_task
    JSR sub_ann_clear_ending_state
    LDA #$60
    STA ram_off_scr_hidden1_up_flag
    LDA #$02
    STA $079c
    RTS

handler_ann_render_ending_guests:
    JSR sub_ann_render_ending_guest_sprites
    LDA ram_ann_fds_music_current
    BNE $c72d
    LDA $079c
    BEQ $c725
    LDA #$01
    STA ram_area_music_queue
    RTS
    LDA ram_ann_hard_mode
    BNE loc_ann_finish_save
    INC ram_oper_mode_task
    RTS

handler_ann_save_ending:
    LDA ram_fds_disk_loader_task
    JSR sub_dispatch_inline_handler
    .word handler_show_ann_disk_prompt
    .word handler_ann_write_save
    .word handler_wait_for_ann_disk_eject
    .word handler_wait_for_ann_disk_insert
    .word handler_reset_ann_disk_loader

tbl_ann_save_file_header:
    .byte $0f, $53, $4d, $32, $53, $41, $56, $45, $20, $e3, $d2, $01, $00, $00, $e3, $d2
    .byte $00

handler_ann_write_save:
    LDA #$07
    JSR $e239
    .word tbl_ann_disk_header_id
    .word tbl_ann_save_file_header
    BEQ loc_ann_finish_save
    INC ram_fds_disk_loader_task
    JMP handler_print_ann_disk_error

loc_ann_finish_save:
    LDA #$d2
    STA off_ann_nmi_sound_handler_high
    LDA #$e5
    STA off_ann_nmi_sound_handler_low
    LDA #$00
    STA ram_fds_disk_loader_task
    STA ram_oper_mode_task
    LDA #$00
    STA ram_oper_mode
    JMP handler_run_ann_disk_loader

tbl_ann_guest_sprite_offsets:
    .incbin "NSMDATA3.bin", $01aa, $006

tbl_ann_guest_sprite_next_offsets:
    .incbin "NSMDATA3.bin", $01b0, $007

tbl_ann_guest_sprite_y:
    .incbin "NSMDATA3.bin", $01b7, $007

tbl_ann_guest_sprite_x:
    .incbin "NSMDATA3.bin", $01be, $008

tbl_ann_guest_sprite_tiles:
    .incbin "NSMDATA3.bin", $01c6, $007

tbl_ann_guest_sprite_attributes:
    .incbin "NSMDATA3.bin", $01cd, $007

sub_ann_render_ending_guest_sprites:
    LDA ram_off_scr_hidden1_up_flag
    BEQ $c7ad
    DEC ram_off_scr_hidden1_up_flag
    RTS
    JSR sub_move_sprites_offscreen
    LDX ram_off_scr_halfway_page
    CPX #$07
    BEQ $c7c8
    LDA ram_offscreen_player_info
    AND #$1f
    BNE $c7de
    INC ram_off_scr_halfway_page
    LDA #$01
    STA ram_square2_sound_queue
    JMP $c7de
    LDA ram_offscreen_player_info
    AND #$1f
    BNE $c7de
    INC ram_off_scr_level_number
    LDA ram_off_scr_level_number
    CMP #$0b
    BCC $c7de
    LDA #$04
    STA ram_off_scr_level_number
    INC ram_offscreen_player_info
    LDA ram_off_scr_halfway_page
    PHA
    TAX
    LDA ram_off_scr_level_number
    CMP #$04
    BCC $c7f8
    SBC #$04
    TAY
    LDA tbl_ann_guest_sprite_offsets, Y
    CMP tbl_ann_guest_sprite_next_offsets, X
    BEQ $c84f
    LDY tbl_ann_guest_sprite_next_offsets, X
    LDA tbl_ann_guest_sprite_y, X
    STA ram_sprite_y_position, Y
    STA $020c, Y
    CLC
    ADC #$08
    STA $0204, Y
    STA $0210, Y
    CLC
    ADC #$08
    STA $0208, Y
    STA $0214, Y
    LDA tbl_ann_guest_sprite_x, X
    STA ram_sprite_x_position, Y
    STA $0207, Y
    STA $020b, Y
    CLC
    ADC #$08
    STA $020f, Y
    STA $0213, Y
    STA $0217, Y
    LDA $c795, X
    STA ram_temp_byte
    LDA $c79c, X
    STA zp_ann_fds_wave_id
    LDX #$00
    LDA ram_temp_byte
    STA ram_sprite_tilenumber, Y
    LDA zp_ann_fds_wave_id
    STA ram_sprite_attributes, Y
    INY
    INY
    INY
    INY
    INC ram_temp_byte
    INX
    CPX #$06
    BNE $c83a
    DEC ram_off_scr_halfway_page
    LDX ram_off_scr_halfway_page
    BNE $c7e6
    PLA
    STA ram_off_scr_halfway_page
    LDA #$30
    STA ram_enemy_spr_data_offset
    LDA #$b8
    STA ram_enemy_y_position
    RTS

tbl_ann_ending_player_names:
    .incbin "NSMDATA3.bin", $0295, $00a

handler_ann_set_ending_player_name:
    LDA #$00
    STA ram_screen_routine_task
    LDX #$04
    LDA ram_current_player
    BEQ $c87d
    LDX #$09
    LDY #$04
    LDA tbl_ann_ending_player_names, X
    STA tbl_ann_thank_you_player_name, Y
    STA tbl_ann_hurrah_player_name, Y
    DEX
    DEY
    BPL $c87f
    RTS

tbl_ann_ending_attributes:
    .incbin "NSMDATA3.bin", $02bd, $009

tbl_ann_ending_palette_nmi:
    .incbin "NSMDATA3.bin", $02c6, $014

tbl_ann_msg_thank_you:
    .incbin "NSMDATA3.bin", $02da, $00d

tbl_ann_thank_you_player_name:
    .incbin "NSMDATA3.bin", $02e7, $00b

tbl_ann_msg_peace_is_paved:
    .incbin "NSMDATA3.bin", $02f2, $016

tbl_ann_msg_kingdom_saved:
    .incbin "NSMDATA3.bin", $0308, $016

tbl_ann_msg_hurrah_to:
    .incbin "NSMDATA3.bin", $031e, $00e

tbl_ann_hurrah_player_name:
    .incbin "NSMDATA3.bin", $032c, $006

tbl_ann_msg_only_hero:
    .incbin "NSMDATA3.bin", $0332, $011

tbl_ann_msg_trip_end:
    .incbin "NSMDATA3.bin", $0343, $017

tbl_ann_msg_long_friendship:
    .incbin "NSMDATA3.bin", $035a, $018

tbl_ann_msg_bonus_points:
    .incbin "NSMDATA3.bin", $0372, $018

tbl_ann_msg_players_left:
    .incbin "NSMDATA3.bin", $038a, $019

tbl_ann_ending_palette_extension:
    .incbin "NSMDATA3.bin", $03a3, $010

tbl_ann_throne_room_map:
    .incbin "NSMDATA3.bin", $03b3, $021

; ANN status, intermission, game-over, and warp text packets

off_ann_game_text_packets:
    .incbin "NSMMAIN.bin", $06ea, $075

off_ann_warp_zone_packet:
    .incbin "NSMMAIN.bin", $075f, $02d

tbl_ann_warp_zone_number_tiles:
    .incbin "NSMMAIN.bin", $078c, $018

tbl_ann_game_text_packet_offsets:
    .byte $00, $27, $46, $51

handler_write_ann_game_text:
    PHA
    TAY
    LDX tbl_ann_game_text_packet_offsets,y
    LDY #$00
bra_copy_ann_game_text_packet:
    LDA off_ann_game_text_packets,x
    CMP #$ff
    BEQ bra_finish_ann_game_text_packet
    STA ram_vram_buffer1,y
    INX
    INY
    BNE bra_copy_ann_game_text_packet
bra_finish_ann_game_text_packet:
    LDA #$00
    STA ram_vram_buffer1,y
    PLA
    BEQ bra_exit_ann_game_text
    TAX
    DEX
    BNE bra_exit_ann_game_text
    LDA ram_numberof_lives
    CLC
    ADC #$01
    CMP #10
    BCC bra_store_ann_world_lives_values
    SBC #10
    LDY #$9f
    STY ram_vram_buffer1+7
bra_store_ann_world_lives_values:
    STA ram_vram_buffer1+8
    JSR sub_calculate_ann_course_display_number
    STA ram_vram_buffer1+19
    LDY ram_level_number
    INY
    STY ram_vram_buffer1+21
bra_exit_ann_game_text:
    RTS

handler_draw_ann_warp_text:
    PHA
    LDY #$ff
bra_copy_ann_warp_zone_packet:
    INY
    LDA off_ann_warp_zone_packet,y
    STA ram_vram_buffer1,y
    BNE bra_copy_ann_warp_zone_packet
    PLA
    SEC
    SBC #$80
    ASL
    ASL
    TAX
    LDY #$00
bra_copy_ann_warp_zone_numbers:
    LDA tbl_ann_warp_zone_number_tiles,x
    STA ram_vram_buffer1+27,y
    INX
    INY
    INY
    INY
    INY
    CPY #$0c
    BCC bra_copy_ann_warp_zone_numbers
    LDA #$2c
    JMP loc_store_primary_vram_buffer_offset

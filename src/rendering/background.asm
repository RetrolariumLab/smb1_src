; -------------------------------------------------------------------------------------
; $00 - temp vram buffer offset
; $01 - temp metatile buffer offset
; $02 - temp metatile graphics table offset
; $03 - used to store attribute bits
; $04 - used to determine attribute table row
; $05 - used to determine attribute table column
; $06 - metatile graphics table address low
; $07 - metatile graphics table address high

; Convert the current metatile column into buffered PPU tile and attribute data

; Outputs:
; VRAM update buffers and attribute accumulation state are updated

; Clobbers:
; A, X, Y
handler_render_area_column:
    LDA ram_current_column_pos  ; store LSB of where we're at
    AND #$01
    STA $05
    LDY ram_vram_buffer2_offset  ; store vram buffer offset
    STY $00
    LDA ram_current_nt_addr_low  ; get current name table address we're supposed to render
    STA ram_vram_buffer2+1,y
    LDA ram_current_nt_addr_high
    STA ram_vram_buffer2,y
    LDA #$9a  ; store length byte of 26 here with d7 set
    STA ram_vram_buffer2+2,y  ; to increment by 32 (in columns)
    LDA #$00  ; init attribute row
    STA $04
    TAX
bra_draw_metatile_column_loop:
    STX $01  ; store init value of 0 or incremented offset for buffer
    LDA ram_metatile_buffer,x  ; get first metatile number, and mask out all but 2 MSB
    AND #%11000000
    STA $03  ; store attribute table bits here
    ASL  ; note that metatile format is:
    ROL  ; %xx000000 - attribute table bits,
    ROL  ; %00xxxxxx - metatile number
    TAY  ; rotate bits to d1-d0 and use as offset here
    LDA tbl_metatile_graphics_pointers_low,y  ; get address to graphics table from here
    STA $06
    LDA tbl_metatile_graphics_pointers_high,y
    STA $07
    LDA ram_metatile_buffer,x  ; get metatile number again
    ASL  ; multiply by 4 and use as tile offset
    ASL
    STA $02
    LDA ram_area_parser_task_num  ; get current task number for level processing and
    AND #%00000001  ; mask out all but LSB, then invert LSB, multiply by 2
    EOR #%00000001  ; to get the correct column position in the metatile,
    ASL  ; then add to the tile offset so we can draw either side
    ADC $02  ; of the metatiles
    TAY
    LDX $00  ; use vram buffer offset from before as X
    LDA ($06),y
    STA ram_vram_buffer2+3,x  ; get first tile number (top left or top right) and store
    INY
    LDA ($06),y  ; now get the second (bottom left or bottom right) and store
    STA ram_vram_buffer2+4,x
    LDY $04  ; get current attribute row
    LDA $05  ; get LSB of current column where we're at, and
    BNE bra_position_right_metatile_attributes  ; branch if set (clear = left attrib, set = right)
    LDA $01  ; get current row we're rendering
    LSR  ; branch if LSB set (clear = top left, set = bottom left)
    BCS bra_position_lower_left_metatile_attributes
    ROL $03  ; rotate attribute bits 3 to the left
    ROL $03  ; thus in d1-d0, for upper left square
    ROL $03
    JMP loc_merge_metatile_attributes
bra_position_right_metatile_attributes:
    LDA $01  ; get LSB of current row we're rendering
    LSR  ; branch if set (clear = top right, set = bottom right)
    BCS bra_advance_metatile_attribute_row
    LSR $03  ; shift attribute bits 4 to the right
    LSR $03  ; thus in d3-d2, for upper right square
    LSR $03
    LSR $03
    JMP loc_merge_metatile_attributes
bra_position_lower_left_metatile_attributes:
    LSR $03  ; shift attribute bits 2 to the right
    LSR $03  ; thus in d5-d4 for lower left square
bra_advance_metatile_attribute_row:
    INC $04  ; move onto next attribute row
loc_merge_metatile_attributes:
    LDA ram_attribute_buffer,y  ; get previously saved bits from before
    ORA $03  ; if any, and put new bits, if any, onto
    STA ram_attribute_buffer,y  ; the old, and store
    INC $00  ; increment vram buffer offset by 2
    INC $00
    LDX $01  ; get current gfx buffer row, and check for
    INX  ; the bottom of the screen
    CPX #$0d
    BCC bra_draw_metatile_column_loop  ; if not there yet, loop back
    LDY $00  ; get current vram buffer offset, increment by 3
    INY  ; (for name table address and length bytes)
    INY
    INY
    LDA #$00
    STA ram_vram_buffer2,y  ; put null terminator at end of data for name table
    STY ram_vram_buffer2_offset  ; store new buffer offset
    INC ram_current_nt_addr_low  ; increment name table address low
    LDA ram_current_nt_addr_low  ; check current low byte
    AND #%00011111  ; if no wraparound, just skip this part
    BNE bra_finish_area_column_render
    LDA #$80  ; if wraparound occurs, make sure low byte stays
    STA ram_current_nt_addr_low  ; just under the status bar
    LDA ram_current_nt_addr_high  ; and then invert d2 of the name table address high
    EOR #%00000100  ; to move onto the next appropriate name table
    STA ram_current_nt_addr_high
bra_finish_area_column_render:
    JMP loc_select_secondary_vram_buffer  ; jump to set buffer to $0341 and leave

; -------------------------------------------------------------------------------------
; $00 - temp attribute table address high (big endian order this time!)
; $01 - temp attribute table address low

sub_render_attribute_tables:
    LDA ram_current_nt_addr_low  ; get low byte of next name table address
    AND #%00011111  ; to be written to, mask out all but 5 LSB,
    SEC  ; subtract four
    SBC #$04
    AND #%00011111  ; mask out bits again and store
    STA $01
    LDA ram_current_nt_addr_high  ; get high byte and branch if borrow not set
    BCS bra_compute_attribute_table_address_high
    EOR #%00000100  ; otherwise invert d2
bra_compute_attribute_table_address_high:
    AND #%00000100  ; mask out all other bits
    ORA #$23  ; add $2300 to the high byte and store
    STA $00
    LDA $01  ; get low byte - 4, divide by 4, add offset for
    LSR  ; attribute table and store
    LSR
    ADC #$c0  ; we should now have the appropriate block of
    STA $01  ; attribute table in our temp address
    LDX #$00
    LDY ram_vram_buffer2_offset  ; get buffer offset
bra_write_attribute_table_buffer:
    LDA $00
    STA ram_vram_buffer2,y  ; store high byte of attribute table address
    LDA $01
    CLC  ; get low byte, add 8 because we want to start
    ADC #$08  ; below the status bar, and store
    STA ram_vram_buffer2+1,y
    STA $01  ; also store in temp again
    LDA ram_attribute_buffer,x  ; fetch current attribute table byte and store
    STA ram_vram_buffer2+3,y  ; in the buffer
    LDA #$01
    STA ram_vram_buffer2+2,y  ; store length of 1 in buffer
    LSR
    STA ram_attribute_buffer,x  ; clear current byte in attribute buffer
    INY  ; increment buffer offset by 4 bytes
    INY
    INY
    INY
    INX  ; increment attribute offset and check to see
    CPX #$07  ; if we're at the end yet
    BCC bra_write_attribute_table_buffer
    STA ram_vram_buffer2,y  ; put null terminator at the end
    STY ram_vram_buffer2_offset  ; store offset in case we want to do any more
loc_select_secondary_vram_buffer:
    LDA #$06
    STA ram_vram_buffer_addr_ctrl  ; set buffer to $0341 and leave
    RTS

; -------------------------------------------------------------------------------------

; $00 - used as temporary counter in sub_color_rotation

tbl_rotating_palette_colors:
.if con_revision_profile = con_revision_profile_vs
    .byte $39, $39, $39, $07, $22, $07
.else
    .byte $27, $27, $27, $17, $07, $17
.endif

tbl_blank_palette_packet:
    .incbin "ju_prg.bin", $09c9, $008

; used based on area type
tbl_area_type_palette_3_colors:
.if con_revision_profile = con_revision_profile_vs
    .incbin "vs_prg.bin", $0bd2, $010
.else
    .incbin "ju_prg.bin", $09d1, $010
.endif

sub_color_rotation:
    LDA ram_frame_counter  ; get frame counter
    AND #$07  ; mask out all but three LSB
    BNE bra_exit_color_rotation  ; branch if not set to zero to do this every eighth frame
    LDX ram_vram_buffer1_offset  ; check vram buffer offset
.if con_revision_profile = con_revision_profile_vs
    CPX #$21
.else
    CPX #$31
.endif
    BCS bra_exit_color_rotation  ; if offset over 48 bytes, branch to leave
    TAY  ; otherwise use frame counter's 3 LSB as offset here
bra_copy_blank_palette_packet:
    LDA tbl_blank_palette_packet,y  ; get blank palette for palette 3
    STA ram_vram_buffer1,x  ; store it in the vram buffer
    INX  ; increment offsets
    INY
    CPY #$08
    BCC bra_copy_blank_palette_packet  ; do this until all bytes are copied
    LDX ram_vram_buffer1_offset  ; get current vram buffer offset
    LDA #$03
    STA $00  ; set counter here
    LDA ram_area_type  ; get area type
    ASL  ; multiply by 4 to get proper offset
    ASL
    TAY  ; save as offset here
bra_copy_area_palette_colors:
    LDA tbl_area_type_palette_3_colors,y  ; fetch palette to be written based on area type
    STA ram_vram_buffer1+3,x  ; store it to overwrite blank palette in vram buffer
    INY
    INX
    DEC $00  ; decrement counter
    BPL bra_copy_area_palette_colors  ; do this until the palette is all copied
    LDX ram_vram_buffer1_offset  ; get current vram buffer offset
    LDY ram_color_rotate_offset  ; get color cycling offset
    LDA tbl_rotating_palette_colors,y
    STA ram_vram_buffer1+4,x  ; get and store current color in second slot of palette
    LDA ram_vram_buffer1_offset
    CLC  ; add seven bytes to vram buffer offset
    ADC #$07
    STA ram_vram_buffer1_offset
    INC ram_color_rotate_offset  ; increment color cycling offset
    LDA ram_color_rotate_offset
    CMP #$06  ; check to see if it's still in range
    BCC bra_exit_color_rotation  ; if so, branch to leave
    LDA #$00
    STA ram_color_rotate_offset  ; otherwise, init to keep it in range
bra_exit_color_rotation:
    RTS  ; leave

.include "rendering/block_updates.asm"

sub_destroy_block_metatile:
    LDA #$00  ; force blank metatile if branched/jumped to this point

sub_write_block_metatile:
    LDY #$03  ; load offset for blank metatile
    CMP #$00  ; check contents of A for blank metatile
    BEQ bra_select_block_metatile_tiles  ; branch if found (unconditional if branched from 8a6b)
    LDY #$00  ; load offset for brick metatile w/ line
.if con_revision_profile = con_revision_profile_ann
    CMP #con_ann_brick_with_coins_line_metatile
.else
    CMP #$58
.endif
    BEQ bra_select_block_metatile_tiles  ; use offset if metatile is brick with coins (w/ line)
    CMP #$51
    BEQ bra_select_block_metatile_tiles  ; use offset if metatile is breakable brick w/ line
    INY  ; increment offset for brick metatile w/o line
.if con_revision_profile = con_revision_profile_ann
    CMP #con_ann_brick_with_coins_metatile
.else
    CMP #$5d
.endif
    BEQ bra_select_block_metatile_tiles  ; use offset if metatile is brick with coins (w/o line)
    CMP #$52
    BEQ bra_select_block_metatile_tiles  ; use offset if metatile is breakable brick w/o line
    INY  ; if any other metatile, increment offset for empty block
bra_select_block_metatile_tiles:
    TYA  ; put Y in A
    LDY ram_vram_buffer1_offset  ; get vram buffer offset
    INY  ; move onto next byte
    JSR sub_put_block_metatile  ; get appropriate block data and write to vram buffer
sub_advance_primary_vram_buffer_offset:
    DEY  ; decrement vram buffer offset
    TYA  ; add 10 bytes to it
    CLC
    ADC #10
    JMP loc_store_primary_vram_buffer_offset  ; branch to store as new vram buffer offset

sub_put_block_metatile:
    STX $00  ; store control bit from ram_spr_data_offset_ctrl
    STY $01  ; store vram buffer offset for next byte
    ASL
    ASL  ; multiply A by four and use as X
    TAX
    LDY #$20  ; load high byte for name table 0
    LDA $06  ; get low byte of block buffer pointer
    CMP #$d0  ; check to see if we're on odd-page block buffer
    BCC bra_compute_block_nametable_address  ; if not, use current high byte
    LDY #$24  ; otherwise load high byte for name table 1
bra_compute_block_nametable_address:
    STY $03  ; save high byte here
    AND #$0f  ; mask out high nybble of block buffer pointer
    ASL  ; multiply by 2 to get appropriate name table low byte
    STA $04  ; and then store it here
    LDA #$00
    STA $05  ; initialize temp high byte
    LDA $02  ; get vertical high nybble offset used in block buffer routine
    CLC
    ADC #$20  ; add 32 pixels for the status bar
    ASL
    ROL $05  ; shift and rotate d7 onto d0 and d6 into carry
    ASL
    ROL $05  ; shift and rotate d6 onto d0 and d5 into carry
    ADC $04  ; add low byte of name table and carry to vertical high nybble
    STA $04  ; and store here
    LDA $05  ; get whatever was in d7 and d6 of vertical high nybble
    ADC #$00  ; add carry
    CLC
    ADC $03  ; then add high byte of name table
    STA $05  ; store here
    LDY $01  ; get vram buffer offset to be used
sub_write_block_or_bridge_metatile:
    LDA tbl_block_metatile_tiles,x  ; write top left and top right
    STA ram_vram_buffer1+2,y  ; tile numbers into first spot
    LDA tbl_block_metatile_tiles+1,x
    STA ram_vram_buffer1+3,y
    LDA tbl_block_metatile_tiles+2,x  ; write bottom left and bottom
    STA ram_vram_buffer1+7,y  ; right tiles numbers into
    LDA tbl_block_metatile_tiles+3,x  ; second spot
    STA ram_vram_buffer1+8,y
    LDA $04
    STA ram_vram_buffer1,y  ; write low byte of name table
    CLC  ; into first slot as read
    ADC #$20  ; add 32 bytes to value
    STA ram_vram_buffer1+5,y  ; write low byte of name table
    LDA $05  ; plus 32 bytes into second slot
    STA ram_vram_buffer1-1,y  ; write high byte of name
    STA ram_vram_buffer1+4,y  ; table address to both slots
    LDA #$02
    STA ram_vram_buffer1+1,y  ; put length of 2 in
    STA ram_vram_buffer1+6,y  ; both slots
    LDA #$00
    STA ram_vram_buffer1+9,y  ; put null terminator at end
    LDX $00  ; get offset control bit here
    RTS  ; and leave

; -------------------------------------------------------------------------------------
; METATILE GRAPHICS TABLE

tbl_metatile_graphics_pointers_low:
    .byte <off_palette_0_metatiles, <off_palette_1_metatiles, <off_palette_2_metatiles, <off_palette_3_metatiles

tbl_metatile_graphics_pointers_high:
    .byte >off_palette_0_metatiles, >off_palette_1_metatiles, >off_palette_2_metatiles, >off_palette_3_metatiles

.if con_revision_profile = con_revision_profile_ann
    .define con_metatile_graphics_asset "../../assets/generated/platforms/ann_fds/source/ann_metatile_graphics.bin"
con_palette_1_metatiles_size = $0bc
con_palette_2_metatiles_offset = $158
.else
    .define con_metatile_graphics_asset "../../assets/generated/source/base_metatile_graphics.bin"
con_palette_1_metatiles_size = $0b8
con_palette_2_metatiles_offset = $154
.endif

off_palette_0_metatiles:
    .incbin con_metatile_graphics_asset, $000, $09c

off_palette_1_metatiles:
    .incbin con_metatile_graphics_asset, $09c, con_palette_1_metatiles_size

off_palette_2_metatiles:
    .incbin con_metatile_graphics_asset, con_palette_2_metatiles_offset, $028

off_palette_3_metatiles:
    .incbin con_metatile_graphics_asset, con_palette_2_metatiles_offset + $028, $018

; -------------------------------------------------------------------------------------
; VRAM BUFFER DATA FOR LOCATIONS IN PRG-ROM

.if con_revision_profile = con_revision_profile_vs
    .define con_area_palette_packets_asset "../../assets/generated/platforms/vs_smb/source/vs_area_palette_packets.bin"
.else
    .define con_area_palette_packets_asset "../../assets/generated/source/base_area_palette_packets.bin"
.endif

off_water_area_palette_packet:
    .incbin con_area_palette_packets_asset, $00, $24

off_ground_area_palette_packet:
    .incbin con_area_palette_packets_asset, $24, $24

off_underground_area_palette_packet:
    .incbin con_area_palette_packets_asset, $48, $24

off_castle_area_palette_packet:
    .incbin con_area_palette_packets_asset, $6c, $24

off_day_snow_palette_packet:
    .incbin con_area_palette_packets_asset, $90, $08

off_night_snow_palette_packet:
    .incbin con_area_palette_packets_asset, $98, $08

off_mushroom_palette_packet:
    .incbin con_area_palette_packets_asset, $a0, $08

off_bowser_palette_packet:
    .incbin con_area_palette_packets_asset, $a8, $08

off_mario_thanks_message:
; "THANK YOU MARIO!"
    .incbin "ju_prg.bin", $0d54, $014

.if con_revision_profile <> con_revision_profile_ann
off_luigi_thanks_message:
; "THANK YOU LUIGI!"
    .incbin "ju_prg.bin", $0d68, $014
.endif

off_mushroom_retainer_saved_message:
; "BUT OUR PRINCESS IS IN"
    .incbin "ju_prg.bin", $0d7c, $02c
; "ANOTHER CASTLE!"
.if con_revision_profile = con_revision_profile_vs
off_vs_victory_attributes:
    .incbin "vs_prg.bin", $0fa9, $009
off_vs_victory_palette_packet:
    .incbin "vs_prg.bin", $0fb2, $014
off_vs_mario_thanks_message:
; "THANK YOU MARIO!"
    .incbin "vs_prg.bin", $0fc6, $018
off_vs_luigi_thanks_message:
; "THANK YOU LUIGI!"
    .incbin "vs_prg.bin", $0fde, $018
off_vs_peace_message:
; "PEACE IS PAVED"
    .incbin "vs_prg.bin", $0ff6, $016
off_vs_kingdom_saved_message:
; "WITH KINGDOM SAVED"
    .incbin "vs_prg.bin", $100c, $016
off_vs_mario_hurrah_message:
; "HURRAH TO  MARIO"
    .incbin "vs_prg.bin", $1022, $014
off_vs_luigi_hurrah_message:
; "HURRAH TO  LUIGI"
    .incbin "vs_prg.bin", $1036, $014
off_vs_only_hero_message:
; "OUR ONLY HERO"
    .incbin "vs_prg.bin", $104a, $011
off_vs_trip_ending_message:
; "THIS ENDS YOUR TRIP"
    .incbin "vs_prg.bin", $105b, $017
off_vs_friendship_message:
; "OF A LONG FRIENDSHIP"
    .incbin "vs_prg.bin", $1072, $018
off_vs_bonus_points_message:
; "100000 PTS.ADDED"
    .incbin "vs_prg.bin", $108a, $018
off_vs_players_left_message:
; "FOR EACH PLAYER LEFT."
    .incbin "vs_prg.bin", $10a2, $019
.elseif con_revision_profile <> con_revision_profile_ann
off_princess_saved_message_1:
; "YOUR QUEST IS OVER."
    .incbin "ju_prg.bin", $0da8, $017

off_princess_saved_message_2:
; "WE PRESENT YOU A NEW QUEST."
    .incbin "ju_prg.bin", $0dbf, $01f

off_world_select_message_1:
; "PUSH BUTTON B"
    .incbin "ju_prg.bin", $0dde, $011

off_world_select_message_2:
; "TO SELECT A WORLD"
    .incbin "ju_prg.bin", $0def, $015
.endif

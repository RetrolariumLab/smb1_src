off_smb2_main_rotating_palette_colors:
    .byte $27, $27, $27, $17, $07, $17

off_smb2_main_blank_palette_packet:
    .incbin "ju_prg.bin", $09c9, $008

; used based on area type
off_smb2_main_area_type_palette_3_colors:
    .incbin "ju_prg.bin", $09d1, $010

sub_smb2_main_color_rotation:
    LDA FrameCounter  ; get frame counter
    AND #$07  ; mask out all but three LSB
    BNE bra_smb2_main_exit_color_rotation  ; branch if not set to zero to do this every eighth frame
    LDX VRAM_Buffer1_Offset  ; check vram buffer offset
    CPX #$31
    BCS bra_smb2_main_exit_color_rotation  ; if offset over 48 bytes, branch to leave
    TAY  ; otherwise use frame counter's 3 LSB as offset here
bra_smb2_main_copy_blank_palette_packet:
    LDA off_smb2_main_blank_palette_packet,y  ; get blank palette for palette 3
    STA VRAM_Buffer1,x  ; store it in the vram buffer
    INX  ; increment offsets
    INY
    CPY #$08
    BCC bra_smb2_main_copy_blank_palette_packet  ; do this until all bytes are copied
    LDX VRAM_Buffer1_Offset  ; get current vram buffer offset
    LDA #$03
    STA $00  ; set counter here
    LDA AreaType  ; get area type
    ASL  ; multiply by 4 to get proper offset
    ASL
    TAY  ; save as offset here
bra_smb2_main_copy_area_palette_colors:
    LDA off_smb2_main_area_type_palette_3_colors,y  ; fetch palette to be written based on area type
    STA VRAM_Buffer1+3,x  ; store it to overwrite blank palette in vram buffer
    INY
    INX
    DEC $00  ; decrement counter
    BPL bra_smb2_main_copy_area_palette_colors  ; do this until the palette is all copied
    LDX VRAM_Buffer1_Offset  ; get current vram buffer offset
    LDY ColorRotateOffset  ; get color cycling offset
    LDA off_smb2_main_rotating_palette_colors,y
    STA VRAM_Buffer1+4,x  ; get and store current color in second slot of palette
    LDA VRAM_Buffer1_Offset
    CLC  ; add seven bytes to vram buffer offset
    ADC #$07
    STA VRAM_Buffer1_Offset
    INC ColorRotateOffset  ; increment color cycling offset
    LDA ColorRotateOffset
    CMP #$06  ; check to see if it's still in range
    BCC bra_smb2_main_exit_color_rotation  ; if so, branch to leave
    LDA #$00
    STA ColorRotateOffset  ; otherwise, init to keep it in range
bra_smb2_main_exit_color_rotation:
    RTS  ; leave

; -------------------------------------------------------------------------------------
; $00 - temp store for offset control bit
; $01 - temp vram buffer offset
; $02 - temp store for vertical high nybble in block buffer routine
; $03 - temp adder for high byte of name table address
; $04, $05 - name table address low/high
; $06, $07 - block buffer address low/high

off_smb2_main_block_metatile_tiles:
    .incbin "ju_prg.bin", $0a39, $014

sub_smb2_main_remove_coin_axe:
    LDY #$41  ; set low byte so offset points to second vram buffer
    LDA #$03  ; load offset for default blank metatile
    LDX AreaType  ; check area type
    BNE bra_smb2_main_write_blank_metatile  ; if not water type, use offset
    LDA #$04  ; otherwise load offset for blank metatile used in water
bra_smb2_main_write_blank_metatile:
    JSR sub_smb2_main_put_block_metatile  ; do a sub to write blank metatile to vram buffer
    LDA #$06
    STA VRAM_Buffer_AddrCtrl  ; set vram address controller to second vram buffer and leave
    RTS

sub_smb2_main_replace_block_metatile:
    JSR sub_smb2_main_write_block_metatile  ; write metatile to vram buffer to replace block object
    INC Block_ResidualCounter  ; increment unused counter (residual code)
    DEC Block_RepFlag,x  ; decrement flag (residual code)
    RTS  ; leave

sub_smb2_main_destroy_block_metatile:
    LDA #$00  ; force blank metatile if branched/jumped to this point

sub_smb2_main_write_block_metatile:
    LDY #$03  ; load offset for blank metatile
    CMP #$00  ; check contents of A for blank metatile
    BEQ bra_smb2_main_select_block_metatile_tiles  ; branch if found (unconditional if destroying metatile)
    LDY #$00  ; load offset for brick metatile w/ line
    CMP #$56
    BEQ bra_smb2_main_select_block_metatile_tiles  ; use offset if metatile is brick with coins (w/ line)
    CMP #$4f
    BEQ bra_smb2_main_select_block_metatile_tiles  ; use offset if metatile is breakable brick w/ line
    INY  ; increment offset for brick metatile w/o line
    CMP #$5c
    BEQ bra_smb2_main_select_block_metatile_tiles  ; use offset if metatile is brick with coins (w/o line)
    CMP #$50
    BEQ bra_smb2_main_select_block_metatile_tiles  ; use offset if metatile is breakable brick w/o line
    INY  ; if any other metatile, increment offset for empty block
bra_smb2_main_select_block_metatile_tiles:
    TYA  ; put Y in A
    LDY VRAM_Buffer1_Offset  ; get vram buffer offset
    INY  ; move onto next byte
    JSR sub_smb2_main_put_block_metatile  ; get appropriate block data and write to vram buffer
sub_smb2_main_advance_primary_vram_buffer_offset:
    DEY  ; decrement vram buffer offset
    TYA  ; add 10 bytes to it
    CLC
    ADC #10
    JMP loc_smb2_main_store_primary_vram_buffer_offset  ; branch to store as new vram buffer offset

sub_smb2_main_put_block_metatile:
    STX $00  ; store control bit from SprDataOffset_Ctrl
    STY $01  ; store vram buffer offset for next byte
    ASL
    ASL  ; multiply A by four and use as X
    TAX
    LDY #$20  ; load high byte for name table 0
    LDA $06  ; get low byte of block buffer pointer
    CMP #$d0  ; check to see if we're on odd-page block buffer
    BCC bra_smb2_main_compute_block_nametable_address  ; if not, use current high byte
    LDY #$24  ; otherwise load high byte for name table 1
bra_smb2_main_compute_block_nametable_address:
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
sub_smb2_main_write_block_or_bridge_metatile:
    LDA off_smb2_main_block_metatile_tiles,x  ; write top left and top right
    STA VRAM_Buffer1+2,y  ; tile numbers into first spot
    LDA off_smb2_main_block_metatile_tiles+1,x
    STA VRAM_Buffer1+3,y
    LDA off_smb2_main_block_metatile_tiles+2,x  ; write bottom left and bottom
    STA VRAM_Buffer1+7,y  ; right tiles numbers into
    LDA off_smb2_main_block_metatile_tiles+3,x  ; second spot
    STA VRAM_Buffer1+8,y
    LDA $04
    STA VRAM_Buffer1,y  ; write low byte of name table
    CLC  ; into first slot as read
    ADC #$20  ; add 32 bytes to value
    STA VRAM_Buffer1+5,y  ; write low byte of name table
    LDA $05  ; plus 32 bytes into second slot
    STA VRAM_Buffer1-1,y  ; write high byte of name
    STA VRAM_Buffer1+4,y  ; table address to both slots
    LDA #$02
    STA VRAM_Buffer1+1,y  ; put length of 2 in
    STA VRAM_Buffer1+6,y  ; both slots
    LDA #$00
    STA VRAM_Buffer1+9,y  ; put null terminator at end
    LDX $00  ; get offset control bit here
    RTS  ; and leave

; -------------------------------------------------------------------------------------
; METATILE GRAPHICS TABLE

tbl_smb2_main_metatile_graphics_pointers_low:
    .byte <off_smb2_main_palette_0_metatiles, <off_smb2_main_palette_1_metatiles, <off_smb2_main_palette_2_metatiles, <off_smb2_main_palette_3_metatiles

tbl_smb2_main_metatile_graphics_pointers_high:
    .byte >off_smb2_main_palette_0_metatiles, >off_smb2_main_palette_1_metatiles, >off_smb2_main_palette_2_metatiles, >off_smb2_main_palette_3_metatiles

off_smb2_main_palette_0_metatiles:
    .byte $24, $24, $24, $24  ; blank
    .incbin "SM2MAIN.bin", $09f1, $08c

off_smb2_main_palette_1_metatiles:
    .incbin "SM2MAIN.bin", $0a7d, $044
    .byte $45, $47, $45, $47  ; breakable brick (not used)
    .byte $45, $47, $45, $47  ; brick with line (power-up)
    .byte $45, $47, $45, $47  ; brick with line (poison shroom)
    .byte $45, $47, $45, $47  ; brick with line (vine)
    .byte $45, $47, $45, $47  ; brick with line (star)
    .byte $45, $47, $45, $47  ; brick with line (coins)
    .byte $45, $47, $45, $47  ; brick with line (1-up)
    .byte $47, $47, $47, $47  ; brick (power-up)
    .byte $47, $47, $47, $47  ; brick (poison shroom)
    .byte $47, $47, $47, $47  ; brick (vine)
    .byte $47, $47, $47, $47  ; brick (star)
    .byte $47, $47, $47, $47  ; brick (coins)
    .byte $47, $47, $47, $47  ; brick (1-up)
    .byte $24, $24, $24, $24  ; hidden block (1 coin)
    .byte $24, $24, $24, $24  ; hidden block (1-up)
    .incbin "NSMMAIN.bin", $0b9f, $040

off_smb2_main_palette_2_metatiles:
    .incbin "SM2MAIN.bin", $0b3d, $034

off_smb2_main_palette_3_metatiles:
    .incbin "SM2MAIN.bin", $0b71, $01c

; ------------------------------------------------------------------------------------

off_smb2_main_water_area_palette_packet:
    .incbin "ju_prg.bin", $0ca4, $024

off_smb2_main_ground_area_palette_packet:
    .incbin "ju_prg.bin", $0cc8, $024

off_smb2_main_underground_area_palette_packet:
    .incbin "ju_prg.bin", $0cec, $024

off_smb2_main_castle_area_palette_packet:
    .incbin "ju_prg.bin", $0d10, $024

off_smb2_main_day_snow_palette_packet:
    .incbin "ju_prg.bin", $0d34, $008

off_smb2_main_night_snow_palette_packet:
    .incbin "ju_prg.bin", $0d3c, $008

off_smb2_main_mushroom_palette_packet:
    .incbin "ju_prg.bin", $0d44, $008

off_smb2_main_bowser_palette_packet:
    .incbin "ju_prg.bin", $0d4c, $008

off_smb2_main_thank_you_message:
    .incbin "ju_prg.bin", $0d54, $014

off_smb2_main_mushroom_retainer_msg:
    .incbin "ju_prg.bin", $0d7c, $02c

; ------------------------------------------------------------------------------------

sub_smb2_main_dispatch_inline_handler:
    ASL  ; shift bit from contents of A
    TAY
    PLA  ; pull saved return address from stack
    STA $04  ; save to indirect
    PLA
    STA $05
    INY
    LDA ($04),y  ; load pointer from indirect
    STA $06  ; note that if an RTS is performed in next routine
    INY  ; it will return to the execution before the sub
    LDA ($04),y  ; that called this routine
    STA $07
    JMP ($0006)  ; jump to the address we loaded

; ------------------------------------------------------------------------------------

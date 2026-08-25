; -------------------------------------------------------------------------------------
; $00 - temp vram buffer offset
; $01 - temp metatile buffer offset
; $02 - temp metatile graphics table offset
; $03 - used to store attribute bits
; $04 - used to determine attribute table row
; $05 - used to determine attribute table column
; $06 - metatile graphics table address low
; $07 - metatile graphics table address high

RenderAreaGraphics:
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
DrawMTLoop:
    STX $01  ; store init value of 0 or incremented offset for buffer
    LDA ram_metatile_buffer,x  ; get first metatile number, and mask out all but 2 MSB
    AND #%11000000
    STA $03  ; store attribute table bits here
    ASL  ; note that metatile format is:
    ROL  ; %xx000000 - attribute table bits,
    ROL  ; %00xxxxxx - metatile number
    TAY  ; rotate bits to d1-d0 and use as offset here
    LDA MetatileGraphics_Low,y  ; get address to graphics table from here
    STA $06
    LDA MetatileGraphics_High,y
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
    BNE RightCheck  ; branch if set (clear = left attrib, set = right)
    LDA $01  ; get current row we're rendering
    LSR  ; branch if LSB set (clear = top left, set = bottom left)
    BCS LLeft
    ROL $03  ; rotate attribute bits 3 to the left
    ROL $03  ; thus in d1-d0, for upper left square
    ROL $03
    JMP SetAttrib
RightCheck:
    LDA $01  ; get LSB of current row we're rendering
    LSR  ; branch if set (clear = top right, set = bottom right)
    BCS NextMTRow
    LSR $03  ; shift attribute bits 4 to the right
    LSR $03  ; thus in d3-d2, for upper right square
    LSR $03
    LSR $03
    JMP SetAttrib
LLeft:
    LSR $03  ; shift attribute bits 2 to the right
    LSR $03  ; thus in d5-d4 for lower left square
NextMTRow:
    INC $04  ; move onto next attribute row
SetAttrib:
    LDA ram_attribute_buffer,y  ; get previously saved bits from before
    ORA $03  ; if any, and put new bits, if any, onto
    STA ram_attribute_buffer,y  ; the old, and store
    INC $00  ; increment vram buffer offset by 2
    INC $00
    LDX $01  ; get current gfx buffer row, and check for
    INX  ; the bottom of the screen
    CPX #$0d
    BCC DrawMTLoop  ; if not there yet, loop back
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
    BNE ExitDrawM
    LDA #$80  ; if wraparound occurs, make sure low byte stays
    STA ram_current_nt_addr_low  ; just under the status bar
    LDA ram_current_nt_addr_high  ; and then invert d2 of the name table address high
    EOR #%00000100  ; to move onto the next appropriate name table
    STA ram_current_nt_addr_high
ExitDrawM:
    JMP SetVRAMCtrl  ; jump to set buffer to $0341 and leave

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
    BCS SetATHigh
    EOR #%00000100  ; otherwise invert d2
SetATHigh:
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
AttribLoop:
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
    BCC AttribLoop
    STA ram_vram_buffer2,y  ; put null terminator at the end
    STY ram_vram_buffer2_offset  ; store offset in case we want to do any more
SetVRAMCtrl:
    LDA #$06
    STA ram_vram_buffer_addr_ctrl  ; set buffer to $0341 and leave
    RTS

; -------------------------------------------------------------------------------------

; $00 - used as temporary counter in sub_color_rotation

ColorRotatePalette:
    .byte $27, $27, $27, $17, $07, $17

BlankPalette:
    .incbin "ju_prg.bin", $09c9, $008

; used based on area type
Palette3Data:
    .incbin "ju_prg.bin", $09d1, $010

sub_color_rotation:
    LDA ram_frame_counter  ; get frame counter
    AND #$07  ; mask out all but three LSB
    BNE ExitColorRot  ; branch if not set to zero to do this every eighth frame
    LDX ram_vram_buffer1_offset  ; check vram buffer offset
    CPX #$31
    BCS ExitColorRot  ; if offset over 48 bytes, branch to leave
    TAY  ; otherwise use frame counter's 3 LSB as offset here
GetBlankPal:
    LDA BlankPalette,y  ; get blank palette for palette 3
    STA ram_vram_buffer1,x  ; store it in the vram buffer
    INX  ; increment offsets
    INY
    CPY #$08
    BCC GetBlankPal  ; do this until all bytes are copied
    LDX ram_vram_buffer1_offset  ; get current vram buffer offset
    LDA #$03
    STA $00  ; set counter here
    LDA ram_area_type  ; get area type
    ASL  ; multiply by 4 to get proper offset
    ASL
    TAY  ; save as offset here
GetAreaPal:
    LDA Palette3Data,y  ; fetch palette to be written based on area type
    STA ram_vram_buffer1+3,x  ; store it to overwrite blank palette in vram buffer
    INY
    INX
    DEC $00  ; decrement counter
    BPL GetAreaPal  ; do this until the palette is all copied
    LDX ram_vram_buffer1_offset  ; get current vram buffer offset
    LDY ram_color_rotate_offset  ; get color cycling offset
    LDA ColorRotatePalette,y
    STA ram_vram_buffer1+4,x  ; get and store current color in second slot of palette
    LDA ram_vram_buffer1_offset
    CLC  ; add seven bytes to vram buffer offset
    ADC #$07
    STA ram_vram_buffer1_offset
    INC ram_color_rotate_offset  ; increment color cycling offset
    LDA ram_color_rotate_offset
    CMP #$06  ; check to see if it's still in range
    BCC ExitColorRot  ; if so, branch to leave
    LDA #$00
    STA ram_color_rotate_offset  ; otherwise, init to keep it in range
ExitColorRot:
    RTS  ; leave

; -------------------------------------------------------------------------------------
; $00 - temp store for offset control bit
; $01 - temp vram buffer offset
; $02 - temp store for vertical high nybble in block buffer routine
; $03 - temp adder for high byte of name table address
; $04, $05 - name table address low/high
; $06, $07 - block buffer address low/high

BlockGfxData:
    .incbin "ju_prg.bin", $0a39, $014

sub_remove_coin_axe:
    LDY #$41  ; set low byte so offset points to $0341
    LDA #$03  ; load offset for default blank metatile
    LDX ram_area_type  ; check area type
    BNE WriteBlankMT  ; if not water type, use offset
    LDA #$04  ; otherwise load offset for blank metatile used in water
WriteBlankMT:
    JSR sub_put_block_metatile  ; do a sub to write blank metatile to vram buffer
    LDA #$06
    STA ram_vram_buffer_addr_ctrl  ; set vram address controller to $0341 and leave
    RTS

sub_replace_block_metatile:
    JSR sub_write_block_metatile  ; write metatile to vram buffer to replace block object
    INC ram_block_residual_counter  ; increment unused counter (residual code)
    DEC ram_block_rep_flag,x  ; decrement flag (residual code)
    RTS  ; leave

sub_destroy_block_metatile:
    LDA #$00  ; force blank metatile if branched/jumped to this point

sub_write_block_metatile:
    LDY #$03  ; load offset for blank metatile
    CMP #$00  ; check contents of A for blank metatile
    BEQ UseBOffset  ; branch if found (unconditional if branched from 8a6b)
    LDY #$00  ; load offset for brick metatile w/ line
    CMP #$58
    BEQ UseBOffset  ; use offset if metatile is brick with coins (w/ line)
    CMP #$51
    BEQ UseBOffset  ; use offset if metatile is breakable brick w/ line
    INY  ; increment offset for brick metatile w/o line
    CMP #$5d
    BEQ UseBOffset  ; use offset if metatile is brick with coins (w/o line)
    CMP #$52
    BEQ UseBOffset  ; use offset if metatile is breakable brick w/o line
    INY  ; if any other metatile, increment offset for empty block
UseBOffset:
    TYA  ; put Y in A
    LDY ram_vram_buffer1_offset  ; get vram buffer offset
    INY  ; move onto next byte
    JSR sub_put_block_metatile  ; get appropriate block data and write to vram buffer
sub_move_v_offset:
    DEY  ; decrement vram buffer offset
    TYA  ; add 10 bytes to it
    CLC
    ADC #10
    JMP SetVRAMOffset  ; branch to store as new vram buffer offset

sub_put_block_metatile:
    STX $00  ; store control bit from ram_spr_data_offset_ctrl
    STY $01  ; store vram buffer offset for next byte
    ASL
    ASL  ; multiply A by four and use as X
    TAX
    LDY #$20  ; load high byte for name table 0
    LDA $06  ; get low byte of block buffer pointer
    CMP #$d0  ; check to see if we're on odd-page block buffer
    BCC SaveHAdder  ; if not, use current high byte
    LDY #$24  ; otherwise load high byte for name table 1
SaveHAdder:
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
sub_rem_bridge:
    LDA BlockGfxData,x  ; write top left and top right
    STA ram_vram_buffer1+2,y  ; tile numbers into first spot
    LDA BlockGfxData+1,x
    STA ram_vram_buffer1+3,y
    LDA BlockGfxData+2,x  ; write bottom left and bottom
    STA ram_vram_buffer1+7,y  ; right tiles numbers into
    LDA BlockGfxData+3,x  ; second spot
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

MetatileGraphics_Low:
    .byte <Palette0_MTiles, <Palette1_MTiles, <Palette2_MTiles, <Palette3_MTiles

MetatileGraphics_High:
    .byte >Palette0_MTiles, >Palette1_MTiles, >Palette2_MTiles, >Palette3_MTiles

Palette0_MTiles:
    .byte $24, $24, $24, $24  ; blank
    .incbin "ju_prg.bin", $0b14, $098

Palette1_MTiles:
    .incbin "ju_prg.bin", $0bac, $05c
    .byte $45, $47, $45, $47  ; brick with line (star)
    .byte $45, $47, $45, $47  ; brick with line (coins)
    .byte $45, $47, $45, $47  ; brick with line (1-up)
    .byte $47, $47, $47, $47  ; brick (power-up)
    .byte $47, $47, $47, $47  ; brick (vine)
    .byte $47, $47, $47, $47  ; brick (star)
    .byte $47, $47, $47, $47  ; brick (coins)
    .byte $47, $47, $47, $47  ; brick (1-up)
    .incbin "ju_prg.bin", $0c28, $03c

Palette2_MTiles:
    .incbin "ju_prg.bin", $0c64, $028

Palette3_MTiles:
    .incbin "ju_prg.bin", $0c8c, $018

; -------------------------------------------------------------------------------------
; VRAM BUFFER DATA FOR LOCATIONS IN PRG-ROM

WaterPaletteData:
    .incbin "ju_prg.bin", $0ca4, $024

GroundPaletteData:
    .incbin "ju_prg.bin", $0cc8, $024

UndergroundPaletteData:
    .incbin "ju_prg.bin", $0cec, $024

CastlePaletteData:
    .incbin "ju_prg.bin", $0d10, $024

DaySnowPaletteData:
    .incbin "ju_prg.bin", $0d34, $008

NightSnowPaletteData:
    .incbin "ju_prg.bin", $0d3c, $008

MushroomPaletteData:
    .incbin "ju_prg.bin", $0d44, $008

BowserPaletteData:
    .incbin "ju_prg.bin", $0d4c, $008

MarioThanksMessage:
; "THANK YOU MARIO!"
    .incbin "ju_prg.bin", $0d54, $014

LuigiThanksMessage:
; "THANK YOU LUIGI!"
    .incbin "ju_prg.bin", $0d68, $014

MushroomRetainerSaved:
; "BUT OUR PRINCESS IS IN"
    .incbin "ju_prg.bin", $0d7c, $02c
; "ANOTHER CASTLE!"

PrincessSaved1:
; "YOUR QUEST IS OVER."
    .incbin "ju_prg.bin", $0da8, $017

PrincessSaved2:
; "WE PRESENT YOU A NEW QUEST."
    .incbin "ju_prg.bin", $0dbf, $01f

WorldSelectMessage1:
; "PUSH BUTTON B"
    .incbin "ju_prg.bin", $0dde, $011

WorldSelectMessage2:
; "TO SELECT A WORLD"
    .incbin "ju_prg.bin", $0def, $015

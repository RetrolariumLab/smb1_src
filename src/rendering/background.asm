;-------------------------------------------------------------------------------------
;$00 - temp vram buffer offset
;$01 - temp metatile buffer offset
;$02 - temp metatile graphics table offset
;$03 - used to store attribute bits
;$04 - used to determine attribute table row
;$05 - used to determine attribute table column
;$06 - metatile graphics table address low
;$07 - metatile graphics table address high

RenderAreaGraphics:
            lda CurrentColumnPos         ;store LSB of where we're at
            and #$01
            sta $05
            ldy VRAM_Buffer2_Offset      ;store vram buffer offset
            sty $00
            lda CurrentNTAddr_Low        ;get current name table address we're supposed to render
            sta VRAM_Buffer2+1,y
            lda CurrentNTAddr_High
            sta VRAM_Buffer2,y
            lda #$9a                     ;store length byte of 26 here with d7 set
            sta VRAM_Buffer2+2,y         ;to increment by 32 (in columns)
            lda #$00                     ;init attribute row
            sta $04
            tax
DrawMTLoop: stx $01                      ;store init value of 0 or incremented offset for buffer
            lda MetatileBuffer,x         ;get first metatile number, and mask out all but 2 MSB
            and #%11000000
            sta $03                      ;store attribute table bits here
            asl                          ;note that metatile format is:
            rol                          ;%xx000000 - attribute table bits,
            rol                          ;%00xxxxxx - metatile number
            tay                          ;rotate bits to d1-d0 and use as offset here
            lda MetatileGraphics_Low,y   ;get address to graphics table from here
            sta $06
            lda MetatileGraphics_High,y
            sta $07
            lda MetatileBuffer,x         ;get metatile number again
            asl                          ;multiply by 4 and use as tile offset
            asl
            sta $02
            lda AreaParserTaskNum        ;get current task number for level processing and
            and #%00000001               ;mask out all but LSB, then invert LSB, multiply by 2
            eor #%00000001               ;to get the correct column position in the metatile,
            asl                          ;then add to the tile offset so we can draw either side
            adc $02                      ;of the metatiles
            tay
            ldx $00                      ;use vram buffer offset from before as X
            lda ($06),y
            sta VRAM_Buffer2+3,x         ;get first tile number (top left or top right) and store
            iny
            lda ($06),y                  ;now get the second (bottom left or bottom right) and store
            sta VRAM_Buffer2+4,x
            ldy $04                      ;get current attribute row
            lda $05                      ;get LSB of current column where we're at, and
            bne RightCheck               ;branch if set (clear = left attrib, set = right)
            lda $01                      ;get current row we're rendering
            lsr                          ;branch if LSB set (clear = top left, set = bottom left)
            bcs LLeft
            rol $03                      ;rotate attribute bits 3 to the left
            rol $03                      ;thus in d1-d0, for upper left square
            rol $03
            jmp SetAttrib
RightCheck: lda $01                      ;get LSB of current row we're rendering
            lsr                          ;branch if set (clear = top right, set = bottom right)
            bcs NextMTRow
            lsr $03                      ;shift attribute bits 4 to the right
            lsr $03                      ;thus in d3-d2, for upper right square
            lsr $03
            lsr $03
            jmp SetAttrib
LLeft:      lsr $03                      ;shift attribute bits 2 to the right
            lsr $03                      ;thus in d5-d4 for lower left square
NextMTRow:  inc $04                      ;move onto next attribute row
SetAttrib:  lda AttributeBuffer,y        ;get previously saved bits from before
            ora $03                      ;if any, and put new bits, if any, onto
            sta AttributeBuffer,y        ;the old, and store
            inc $00                      ;increment vram buffer offset by 2
            inc $00
            ldx $01                      ;get current gfx buffer row, and check for
            inx                          ;the bottom of the screen
            cpx #$0d
            bcc DrawMTLoop               ;if not there yet, loop back
            ldy $00                      ;get current vram buffer offset, increment by 3
            iny                          ;(for name table address and length bytes)
            iny
            iny
            lda #$00
            sta VRAM_Buffer2,y           ;put null terminator at end of data for name table
            sty VRAM_Buffer2_Offset      ;store new buffer offset
            inc CurrentNTAddr_Low        ;increment name table address low
            lda CurrentNTAddr_Low        ;check current low byte
            and #%00011111               ;if no wraparound, just skip this part
            bne ExitDrawM
            lda #$80                     ;if wraparound occurs, make sure low byte stays
            sta CurrentNTAddr_Low        ;just under the status bar
            lda CurrentNTAddr_High       ;and then invert d2 of the name table address high
            eor #%00000100               ;to move onto the next appropriate name table
            sta CurrentNTAddr_High
ExitDrawM:  jmp SetVRAMCtrl              ;jump to set buffer to $0341 and leave

;-------------------------------------------------------------------------------------
;$00 - temp attribute table address high (big endian order this time!)
;$01 - temp attribute table address low

RenderAttributeTables:
             lda CurrentNTAddr_Low    ;get low byte of next name table address
             and #%00011111           ;to be written to, mask out all but 5 LSB,
             sec                      ;subtract four
             sbc #$04
             and #%00011111           ;mask out bits again and store
             sta $01
             lda CurrentNTAddr_High   ;get high byte and branch if borrow not set
             bcs SetATHigh
             eor #%00000100           ;otherwise invert d2
SetATHigh:   and #%00000100           ;mask out all other bits
             ora #$23                 ;add $2300 to the high byte and store
             sta $00
             lda $01                  ;get low byte - 4, divide by 4, add offset for
             lsr                      ;attribute table and store
             lsr
             adc #$c0                 ;we should now have the appropriate block of
             sta $01                  ;attribute table in our temp address
             ldx #$00
             ldy VRAM_Buffer2_Offset  ;get buffer offset
AttribLoop:  lda $00
             sta VRAM_Buffer2,y       ;store high byte of attribute table address
             lda $01
             clc                      ;get low byte, add 8 because we want to start
             adc #$08                 ;below the status bar, and store
             sta VRAM_Buffer2+1,y
             sta $01                  ;also store in temp again
             lda AttributeBuffer,x    ;fetch current attribute table byte and store
             sta VRAM_Buffer2+3,y     ;in the buffer
             lda #$01
             sta VRAM_Buffer2+2,y     ;store length of 1 in buffer
             lsr
             sta AttributeBuffer,x    ;clear current byte in attribute buffer
             iny                      ;increment buffer offset by 4 bytes
             iny
             iny
             iny
             inx                      ;increment attribute offset and check to see
             cpx #$07                 ;if we're at the end yet
             bcc AttribLoop
             sta VRAM_Buffer2,y       ;put null terminator at the end
             sty VRAM_Buffer2_Offset  ;store offset in case we want to do any more
SetVRAMCtrl: lda #$06
             sta VRAM_Buffer_AddrCtrl ;set buffer to $0341 and leave
             rts

;-------------------------------------------------------------------------------------

;$00 - used as temporary counter in ColorRotation

ColorRotatePalette:
       .byte $27, $27, $27, $17, $07, $17

BlankPalette:
       .incbin "ju_prg.bin", $09c9, $008

;used based on area type
Palette3Data:
       .incbin "ju_prg.bin", $09d1, $010

ColorRotation:
              lda FrameCounter         ;get frame counter
              and #$07                 ;mask out all but three LSB
              bne ExitColorRot         ;branch if not set to zero to do this every eighth frame
              ldx VRAM_Buffer1_Offset  ;check vram buffer offset
              cpx #$31
              bcs ExitColorRot         ;if offset over 48 bytes, branch to leave
              tay                      ;otherwise use frame counter's 3 LSB as offset here
GetBlankPal:  lda BlankPalette,y       ;get blank palette for palette 3
              sta VRAM_Buffer1,x       ;store it in the vram buffer
              inx                      ;increment offsets
              iny
              cpy #$08
              bcc GetBlankPal          ;do this until all bytes are copied
              ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
              lda #$03
              sta $00                  ;set counter here
              lda AreaType             ;get area type
              asl                      ;multiply by 4 to get proper offset
              asl
              tay                      ;save as offset here
GetAreaPal:   lda Palette3Data,y       ;fetch palette to be written based on area type
              sta VRAM_Buffer1+3,x     ;store it to overwrite blank palette in vram buffer
              iny
              inx
              dec $00                  ;decrement counter
              bpl GetAreaPal           ;do this until the palette is all copied
              ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
              ldy ColorRotateOffset    ;get color cycling offset
              lda ColorRotatePalette,y
              sta VRAM_Buffer1+4,x     ;get and store current color in second slot of palette
              lda VRAM_Buffer1_Offset
              clc                      ;add seven bytes to vram buffer offset
              adc #$07
              sta VRAM_Buffer1_Offset
              inc ColorRotateOffset    ;increment color cycling offset
              lda ColorRotateOffset
              cmp #$06                 ;check to see if it's still in range
              bcc ExitColorRot         ;if so, branch to leave
              lda #$00
              sta ColorRotateOffset    ;otherwise, init to keep it in range
ExitColorRot: rts                      ;leave

;-------------------------------------------------------------------------------------
;$00 - temp store for offset control bit
;$01 - temp vram buffer offset
;$02 - temp store for vertical high nybble in block buffer routine
;$03 - temp adder for high byte of name table address
;$04, $05 - name table address low/high
;$06, $07 - block buffer address low/high

BlockGfxData:
       .incbin "ju_prg.bin", $0a39, $014

RemoveCoin_Axe:
              ldy #$41                 ;set low byte so offset points to $0341
              lda #$03                 ;load offset for default blank metatile
              ldx AreaType             ;check area type
              bne WriteBlankMT         ;if not water type, use offset
              lda #$04                 ;otherwise load offset for blank metatile used in water
WriteBlankMT: jsr PutBlockMetatile     ;do a sub to write blank metatile to vram buffer
              lda #$06
              sta VRAM_Buffer_AddrCtrl ;set vram address controller to $0341 and leave
              rts

ReplaceBlockMetatile:
       jsr WriteBlockMetatile    ;write metatile to vram buffer to replace block object
       inc Block_ResidualCounter ;increment unused counter (residual code)
       dec Block_RepFlag,x       ;decrement flag (residual code)
       rts                       ;leave

DestroyBlockMetatile:
       lda #$00       ;force blank metatile if branched/jumped to this point

WriteBlockMetatile:
             ldy #$03                ;load offset for blank metatile
             cmp #$00                ;check contents of A for blank metatile
             beq UseBOffset          ;branch if found (unconditional if branched from 8a6b)
             ldy #$00                ;load offset for brick metatile w/ line
             cmp #$58
             beq UseBOffset          ;use offset if metatile is brick with coins (w/ line)
             cmp #$51
             beq UseBOffset          ;use offset if metatile is breakable brick w/ line
             iny                     ;increment offset for brick metatile w/o line
             cmp #$5d
             beq UseBOffset          ;use offset if metatile is brick with coins (w/o line)
             cmp #$52
             beq UseBOffset          ;use offset if metatile is breakable brick w/o line
             iny                     ;if any other metatile, increment offset for empty block
UseBOffset:  tya                     ;put Y in A
             ldy VRAM_Buffer1_Offset ;get vram buffer offset
             iny                     ;move onto next byte
             jsr PutBlockMetatile    ;get appropriate block data and write to vram buffer
MoveVOffset: dey                     ;decrement vram buffer offset
             tya                     ;add 10 bytes to it
             clc
             adc #10
             jmp SetVRAMOffset       ;branch to store as new vram buffer offset

PutBlockMetatile:
            stx $00               ;store control bit from SprDataOffset_Ctrl
            sty $01               ;store vram buffer offset for next byte
            asl
            asl                   ;multiply A by four and use as X
            tax
            ldy #$20              ;load high byte for name table 0
            lda $06               ;get low byte of block buffer pointer
            cmp #$d0              ;check to see if we're on odd-page block buffer
            bcc SaveHAdder        ;if not, use current high byte
            ldy #$24              ;otherwise load high byte for name table 1
SaveHAdder: sty $03               ;save high byte here
            and #$0f              ;mask out high nybble of block buffer pointer
            asl                   ;multiply by 2 to get appropriate name table low byte
            sta $04               ;and then store it here
            lda #$00
            sta $05               ;initialize temp high byte
            lda $02               ;get vertical high nybble offset used in block buffer routine
            clc
            adc #$20              ;add 32 pixels for the status bar
            asl
            rol $05               ;shift and rotate d7 onto d0 and d6 into carry
            asl
            rol $05               ;shift and rotate d6 onto d0 and d5 into carry
            adc $04               ;add low byte of name table and carry to vertical high nybble
            sta $04               ;and store here
            lda $05               ;get whatever was in d7 and d6 of vertical high nybble
            adc #$00              ;add carry
            clc
            adc $03               ;then add high byte of name table
            sta $05               ;store here
            ldy $01               ;get vram buffer offset to be used
RemBridge:  lda BlockGfxData,x    ;write top left and top right
            sta VRAM_Buffer1+2,y  ;tile numbers into first spot
            lda BlockGfxData+1,x
            sta VRAM_Buffer1+3,y
            lda BlockGfxData+2,x  ;write bottom left and bottom
            sta VRAM_Buffer1+7,y  ;right tiles numbers into
            lda BlockGfxData+3,x  ;second spot
            sta VRAM_Buffer1+8,y
            lda $04
            sta VRAM_Buffer1,y    ;write low byte of name table
            clc                   ;into first slot as read
            adc #$20              ;add 32 bytes to value
            sta VRAM_Buffer1+5,y  ;write low byte of name table
            lda $05               ;plus 32 bytes into second slot
            sta VRAM_Buffer1-1,y  ;write high byte of name
            sta VRAM_Buffer1+4,y  ;table address to both slots
            lda #$02
            sta VRAM_Buffer1+1,y  ;put length of 2 in
            sta VRAM_Buffer1+6,y  ;both slots
            lda #$00
            sta VRAM_Buffer1+9,y  ;put null terminator at end
            ldx $00               ;get offset control bit here
            rts                   ;and leave

;-------------------------------------------------------------------------------------
;METATILE GRAPHICS TABLE

MetatileGraphics_Low:
  .byte <Palette0_MTiles, <Palette1_MTiles, <Palette2_MTiles, <Palette3_MTiles

MetatileGraphics_High:
  .byte >Palette0_MTiles, >Palette1_MTiles, >Palette2_MTiles, >Palette3_MTiles

Palette0_MTiles:
  .byte $24, $24, $24, $24 ;blank
  .incbin "ju_prg.bin", $0b14, $098

Palette1_MTiles:
  .incbin "ju_prg.bin", $0bac, $05c
  .byte $45, $47, $45, $47 ;brick with line (star)
  .byte $45, $47, $45, $47 ;brick with line (coins)
  .byte $45, $47, $45, $47 ;brick with line (1-up)
  .byte $47, $47, $47, $47 ;brick (power-up)
  .byte $47, $47, $47, $47 ;brick (vine)
  .byte $47, $47, $47, $47 ;brick (star)
  .byte $47, $47, $47, $47 ;brick (coins)
  .byte $47, $47, $47, $47 ;brick (1-up)
  .incbin "ju_prg.bin", $0c28, $03c

Palette2_MTiles:
  .incbin "ju_prg.bin", $0c64, $028

Palette3_MTiles:
  .incbin "ju_prg.bin", $0c8c, $018

;-------------------------------------------------------------------------------------
;VRAM BUFFER DATA FOR LOCATIONS IN PRG-ROM

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
;"THANK YOU MARIO!"
  .incbin "ju_prg.bin", $0d54, $014

LuigiThanksMessage:
;"THANK YOU LUIGI!"
  .incbin "ju_prg.bin", $0d68, $014

MushroomRetainerSaved:
;"BUT OUR PRINCESS IS IN"
  .incbin "ju_prg.bin", $0d7c, $02c
;"ANOTHER CASTLE!"

PrincessSaved1:
;"YOUR QUEST IS OVER."
  .incbin "ju_prg.bin", $0da8, $017

PrincessSaved2:
;"WE PRESENT YOU A NEW QUEST."
  .incbin "ju_prg.bin", $0dbf, $01f

WorldSelectMessage1:
;"PUSH BUTTON B"
  .incbin "ju_prg.bin", $0dde, $011

WorldSelectMessage2:
;"TO SELECT A WORLD"
  .incbin "ju_prg.bin", $0def, $015

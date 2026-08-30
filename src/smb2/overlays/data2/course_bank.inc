; SMB2J DISASSEMBLY (SM2DATA2 portion)

; -------------------------------------------------------------------------------------
; DEFINES

FrameCounter          = $09
Enemy_State           = $1e
Enemy_Y_Position      = $cf
PiranhaPlantUpYPos    = $0417
PiranhaPlantDownYPos  = $0434
PiranhaPlant_Y_Speed  = $58
PiranhaPlant_MoveFlag = $a0

Player_X_Scroll       = $06ff

Player_PageLoc        = $6d
Player_X_Position     = $86

AreaObjectLength      = $0730
WindFlag              = $07f9
AreaType              = $074e

TimerControl          = $0747
EnemyFrameTimer       = $078a

Sprite_Y_Position     = $0200
Sprite_Tilenumber     = $0201
Sprite_Attributes     = $0202
Sprite_X_Position     = $0203

Alt_SprDataOffset     = $06ec

NoiseSoundQueue       = $fd

MetatileBuffer        = $06a1

; import from other files
.import sub_smb2_main_get_pipe_height
.import sub_smb2_main_find_empty_enemy_slot
.import sub_smb2_main_setup_piranha_plant
.import off_smb2_main_vertical_pipe_metatiles
.import sub_smb2_main_render_under_part
; export to other files
.export off_smb2_data2_castle_area_5_enemies
.export off_smb2_data2_castle_area_6_enemies
.export off_smb2_data2_e_castle_area7
.export off_smb2_data2_e_castle_area8
.export off_smb2_data2_ground_area_12_enemies
.export off_smb2_data2_ground_area_13_enemies
.export off_smb2_data2_ground_area_14_enemies
.export off_smb2_data2_ground_area_15_enemies
.export off_smb2_data2_ground_area_16_enemies
.export off_smb2_data2_ground_area_17_enemies
.export off_smb2_data2_ground_area_18_enemies
.export off_smb2_data2_ground_area_19_enemies
.export off_smb2_data2_ground_area_22_enemies
.export off_smb2_data2_e_ground_area23
.export off_smb2_data2_e_ground_area24
.export off_smb2_data2_e_ground_area29
.export off_smb2_data2_e_underground_area4
.export off_smb2_data2_e_underground_area5
.export off_smb2_data2_water_area_2_enemies
.export off_smb2_data2_e_water_area4
.export off_smb2_data2_e_water_area5
.export off_smb2_data2_castle_area_5_objects
.export off_smb2_data2_castle_area_6_objects
.export off_smb2_data2_l_castle_area7
.export off_smb2_data2_l_castle_area8
.export off_smb2_data2_ground_area_12_objects
.export off_smb2_data2_ground_area_13_objects
.export off_smb2_data2_ground_area_14_objects
.export off_smb2_data2_ground_area_15_objects
.export off_smb2_data2_ground_area_16_objects
.export off_smb2_data2_ground_area_17_objects
.export off_smb2_data2_ground_area_18_objects
.export off_smb2_data2_ground_area_19_objects
.export off_smb2_data2_ground_area_22_objects
.export off_smb2_data2_l_ground_area23
.export off_smb2_data2_l_ground_area24
.export off_smb2_data2_l_ground_area29
.export off_smb2_data2_l_underground_area4
.export off_smb2_data2_l_underground_area5
.export off_smb2_data2_water_area_2_objects
.export off_smb2_data2_l_water_area4
.export off_smb2_data2_l_water_area5

; -------------------------------------------------------------------------------------------------
; $06 - used to store vertical length of pipe
; $07 - starts with adder from area parser, used to store row offset

loc_smb2_data2_upside_down_pipe_high:
    LDA #$01  ; start at second row
    PHA
    BNE bra_smb2_data2_render_upside_down_pipe_body
loc_smb2_data2_upside_down_pipe_low:
    LDA #$04  ; start at fifth row
    PHA
bra_smb2_data2_render_upside_down_pipe_body:
    JSR sub_smb2_main_get_pipe_height  ; get pipe height from object byte
    PLA
    STA $07  ; save buffer offset temporarily
    TYA
    PHA  ; save pipe height temporarily
    LDY AreaObjectLength,x  ; if on second column of pipe, skip this
    BEQ bra_smb2_data2_finish_upside_down_pipe
    JSR sub_smb2_main_find_empty_enemy_slot  ; otherwise try to insert upside-down
    BCS bra_smb2_data2_finish_upside_down_pipe  ; piranha plant, if no empty slots, skip this
    LDA #$04
    JSR sub_smb2_main_setup_piranha_plant  ; set up upside-down piranha plant
    LDA $06
    ASL
    ASL  ; multiply height of pipe by 16
    ASL  ; and add enemy Y position previously set up
    ASL  ; then subtract 10 pixels, save as new Y position
    CLC
    ADC Enemy_Y_Position,x
    SEC
    SBC #$0a
    STA Enemy_Y_Position,x
    STA PiranhaPlantDownYPos,x  ; set as "down" position
    CLC  ; add 24 pixels, save as "up" position
    ADC #$18  ; note up and down here are reversed
    STA PiranhaPlantUpYPos,x
    INC PiranhaPlant_MoveFlag,x  ; set movement flag
bra_smb2_data2_finish_upside_down_pipe:
    PLA
    TAY  ; return tile offset
    PHA
    LDX $07
    LDA off_smb2_main_vertical_pipe_metatiles+2,y
    LDY $06  ; render the pipe shaft
    DEY
    JSR sub_smb2_main_render_under_part
    PLA
    TAY
    LDA off_smb2_main_vertical_pipe_metatiles,y  ; and render the pipe end
    STA MetatileBuffer,x
    RTS

    RTS  ; unused, nothing jumps here

loc_smb2_data2_move_upside_down_piranha_plant:
    LDA Enemy_State,x  ; check enemy state
    BNE bra_smb2_data2_exit_upside_down_piranha_movement  ; if set at all, branch to leave
    LDA EnemyFrameTimer,x  ; check enemy's timer here
    BNE bra_smb2_data2_exit_upside_down_piranha_movement  ; branch to end if not yet expired
    LDA PiranhaPlant_MoveFlag,x  ; check movement flag
    BNE bra_smb2_data2_select_piranha_plant_limit  ; if moving, skip to part ahead
    LDA PiranhaPlant_Y_Speed,x  ; get vertical speed
    EOR #$ff
    CLC  ; change to two's compliment
    ADC #$01
    STA PiranhaPlant_Y_Speed,x  ; save as new vertical speed
    INC PiranhaPlant_MoveFlag,x  ; increment to set movement flag

bra_smb2_data2_select_piranha_plant_limit:
    LDA PiranhaPlantUpYPos,x  ; get original vertical coordinate (lowest point)
    LDY PiranhaPlant_Y_Speed,x  ; get vertical speed
    BPL bra_smb2_data2_move_piranha_plant  ; branch if moving downwards
    LDA PiranhaPlantDownYPos,x  ; otherwise get other vertical coordinate (highest point)

bra_smb2_data2_move_piranha_plant:
    STA $00  ; save vertical coordinate here
    LDA TimerControl  ; get master timer control
    BNE bra_smb2_data2_exit_upside_down_piranha_movement  ; branch to leave if set (likely not necessary)
    LDA Enemy_Y_Position,x  ; get current vertical coordinate
    CLC
    ADC PiranhaPlant_Y_Speed,x  ; add vertical speed to move up or down
    STA Enemy_Y_Position,x  ; save as new vertical coordinate
    CMP $00  ; compare against low or high coordinate
    BNE bra_smb2_data2_exit_upside_down_piranha_movement  ; branch to leave if not yet reached
    LDA #$00
    STA PiranhaPlant_MoveFlag,x  ; otherwise clear movement flag
    LDA #$20
    STA EnemyFrameTimer,x  ; set timer to delay piranha plant movement
bra_smb2_data2_exit_upside_down_piranha_movement:
    RTS

; -------------------------------------------------------------------------------------

loc_smb2_data2_blow_player_around:
    LDA WindFlag  ; if wind is turned off, just exit
    BEQ bra_smb2_data2_exit_wind_player_push
    LDA AreaType  ; don't blow the player around unless
    CMP #$01  ; the area is ground type
    BNE bra_smb2_data2_exit_wind_player_push
    LDY #$01
    LDA FrameCounter  ; branch to set d0 if on an odd frame
    ASL
    BCS bra_smb2_data2_gate_wind_push_by_frame  ; otherwise wind will only blow
    LDY #$03  ; one out of every four frames
bra_smb2_data2_gate_wind_push_by_frame:
    STY $00
    LDA FrameCounter  ; throttle wind blowing by using the frame counter
    AND $00  ; to mask out certain frames
    BNE bra_smb2_data2_exit_wind_player_push
    LDA Player_X_Position  ; move player slightly to the right
    CLC  ; to simulate the wind moving the player
    ADC #$01
    STA Player_X_Position
    LDA Player_PageLoc
    ADC #$00
    STA Player_PageLoc
    INC Player_X_Scroll  ; add one to movement speed for scroll
bra_smb2_data2_exit_wind_player_push:
    RTS

; note the position data values are overwritten in RAM
tbl_smb2_data2_leaves_y_pos:
    .byte $30, $70, $b8, $50, $98, $30
    .byte $70, $b8, $50, $98, $30, $70

tbl_smb2_data2_leaves_x_pos:
    .byte $30, $30, $30, $60, $60, $a0
    .byte $a0, $a0, $d0, $d0, $d0, $60

tbl_smb2_data2_leaves_tile:
    .byte $7b, $7b, $7b, $7b, $7a, $7a
    .byte $7b, $7b, $7b, $7a, $7b, $7a

loc_smb2_data2_simulate_wind:
    LDA WindFlag  ; if no wind, branch to leave
    BEQ bra_smb2_data2_exit_wind_simulation
    LDA #$04  ; play wind sfx
    STA NoiseSoundQueue
    JSR sub_smb2_data2_modify_leaves_pos  ; modify X and Y position data of leaves
    LDX #$00  ; use mostly unused sprite data offset
    LDY Alt_SprDataOffset-1  ; for first six leaves
bra_smb2_data2_draw_wind_leaf:
    LDA tbl_smb2_data2_leaves_y_pos,x
    STA Sprite_Y_Position,y  ; set up sprite data in OAM memory
    LDA tbl_smb2_data2_leaves_tile,x
    STA Sprite_Tilenumber,y
    LDA #$41
    STA Sprite_Attributes,y
    LDA tbl_smb2_data2_leaves_x_pos,x
    STA Sprite_X_Position,y
    INY
    INY
    INY
    INY
    INX  ; if still on first six leaves, continue
    CPX #$06  ; using the first sprite data offset
    BNE bra_smb2_data2_draw_wind_leaves_loop  ; otherwise use the next one instead
    LDY Alt_SprDataOffset  ; note the next one is also used by blocks
bra_smb2_data2_draw_wind_leaves_loop:
    CPX #$0c  ; continue until done putting all leaves on the screen
    BNE bra_smb2_data2_draw_wind_leaf
bra_smb2_data2_exit_wind_simulation:
    RTS

tbl_smb2_data2_leaves_pos_adder:
    .byte $57, $57, $56, $56, $58, $58, $56, $56, $57, $58, $57, $58
    .byte $59, $59, $58, $58, $5a, $5a, $58, $58, $59, $5a, $59, $5a

sub_smb2_data2_modify_leaves_pos:
    LDX #$0b
bra_smb2_data2_update_wind_leaf_positions_loop:
    LDA tbl_smb2_data2_leaves_x_pos,x  ; add each adder to each X position twice
    CLC  ; and to each Y position once
    ADC tbl_smb2_data2_leaves_pos_adder,x
    ADC tbl_smb2_data2_leaves_pos_adder,x
    STA tbl_smb2_data2_leaves_x_pos,x
    LDA tbl_smb2_data2_leaves_y_pos,x
    CLC
    ADC tbl_smb2_data2_leaves_pos_adder,x
    STA tbl_smb2_data2_leaves_y_pos,x
    DEX
    BPL bra_smb2_data2_update_wind_leaf_positions_loop
    RTS

loc_smb2_data2_wind_on:
    LDA #$01  ; branch to turn the wind on
    BNE bra_smb2_data2_store_wind_state
loc_smb2_data2_wind_off:
    LDA #$00  ; turn the wind off
bra_smb2_data2_store_wind_state:
    STA WindFlag
    RTS

; some unused bytes
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

; -------------------------------------------------------------------------------------

; level 5-4
off_smb2_data2_castle_area_5_enemies:
    .incbin "SM2DATA2.bin", $0160, $039

; level 6-4
off_smb2_data2_castle_area_6_enemies:
    .incbin "SM2DATA2.bin", $0199, $027

; level 7-4
off_smb2_data2_e_castle_area7:
    .incbin "SM2DATA2.bin", $01c0, $03f

; level 8-4
off_smb2_data2_e_castle_area8:
    .incbin "SM2DATA2.bin", $01ff, $040

; level 5-1
off_smb2_data2_ground_area_12_enemies:
    .incbin "SM2DATA2.bin", $023f, $031

; level 5-3
off_smb2_data2_ground_area_13_enemies:
    .incbin "SM2DATA2.bin", $0270, $028

; level 6-1
off_smb2_data2_ground_area_14_enemies:
    .incbin "SM2DATA2.bin", $0298, $024

; level 6-3
off_smb2_data2_ground_area_15_enemies:
    .incbin "SM2DATA2.bin", $02bc, $01d

; level 7-1
off_smb2_data2_ground_area_16_enemies:
    .incbin "SM2DATA2.bin", $02d9, $031

; level 7-2
off_smb2_data2_ground_area_17_enemies:
    .incbin "SM2DATA2.bin", $030a, $02c

; level 7-3
off_smb2_data2_ground_area_18_enemies:
    .incbin "SM2DATA2.bin", $0336, $019

; level 8-1
off_smb2_data2_ground_area_19_enemies:
    .incbin "SM2DATA2.bin", $034f, $028

; level 8-2
off_smb2_data2_ground_area_22_enemies:
    .incbin "SM2DATA2.bin", $0377, $023

; level 8-3
off_smb2_data2_e_ground_area23:
    .incbin "SM2DATA2.bin", $039a, $027
; another unused area
off_smb2_data2_e_ground_area24:
    .byte $ff

; cloud level used with level 5-1
off_smb2_data2_e_ground_area29:
    .incbin "SM2DATA2.bin", $03c2, $009

; level 5-2
off_smb2_data2_e_underground_area4:
    .incbin "SM2DATA2.bin", $03cb, $021

; underground bonus rooms used with worlds 5-8
off_smb2_data2_e_underground_area5:
    .incbin "SM2DATA2.bin", $03ec, $01a

; level 6-2
off_smb2_data2_water_area_2_enemies:
    .incbin "SM2DATA2.bin", $0406, $030

; water area used in level 8-4
off_smb2_data2_e_water_area4:
    .incbin "SM2DATA2.bin", $0436, $00e

; water area used in level 6-1
off_smb2_data2_e_water_area5:
    .incbin "SM2DATA2.bin", $0444, $015

; level 5-4
off_smb2_data2_castle_area_5_objects:
    .incbin "SM2DATA2.bin", $0459, $0cd

; level 6-4
off_smb2_data2_castle_area_6_objects:
    .incbin "SM2DATA2.bin", $0526, $08f

; level 7-4
off_smb2_data2_l_castle_area7:
    .incbin "SM2DATA2.bin", $05b5, $093

; level 8-4
off_smb2_data2_l_castle_area8:
    .incbin "SM2DATA2.bin", $0648, $0d7

; level 5-1
off_smb2_data2_ground_area_12_objects:
    .incbin "SM2DATA2.bin", $071f, $0a1

; level 5-3
off_smb2_data2_ground_area_13_objects:
    .incbin "SM2DATA2.bin", $07c0, $05f

; level 6-1
off_smb2_data2_ground_area_14_objects:
    .incbin "SM2DATA2.bin", $081f, $07f

; level 6-3
off_smb2_data2_ground_area_15_objects:
    .incbin "SM2DATA2.bin", $089e, $06d

; level 7-1
off_smb2_data2_ground_area_16_objects:
    .incbin "SM2DATA2.bin", $090b, $083

; level 7-2
off_smb2_data2_ground_area_17_objects:
    .incbin "SM2DATA2.bin", $098e, $05d

; level 7-3
off_smb2_data2_ground_area_18_objects:
    .incbin "SM2DATA2.bin", $09eb, $07b

; level 8-1
off_smb2_data2_ground_area_19_objects:
    .incbin "SM2DATA2.bin", $0a66, $075

; level 8-2
off_smb2_data2_ground_area_22_objects:
    .incbin "SM2DATA2.bin", $0adb, $06b

; level 8-3
off_smb2_data2_l_ground_area23:
    .incbin "SM2DATA2.bin", $0b46, $064
; another unused area
off_smb2_data2_l_ground_area24:
    .byte $fd

; cloud level used with level 5-1
off_smb2_data2_l_ground_area29:
    .incbin "SM2DATA2.bin", $0bab, $037

; level 5-2
off_smb2_data2_l_underground_area4:
    .incbin "SM2DATA2.bin", $0be2, $0cd

; underground bonus rooms used with worlds 5-8
off_smb2_data2_l_underground_area5:
    .incbin "SM2DATA2.bin", $0caf, $041

; level 6-2
off_smb2_data2_water_area_2_objects:
    .incbin "SM2DATA2.bin", $0cf0, $0c9

; water area used in level 8-4
off_smb2_data2_l_water_area4:
    .incbin "SM2DATA2.bin", $0db9, $019

; water area used in level 6-1
off_smb2_data2_l_water_area5:
    .incbin "SM2DATA2.bin", $0dd2, $04f

; unused bytes
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

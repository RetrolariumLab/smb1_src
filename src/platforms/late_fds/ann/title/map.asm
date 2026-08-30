; Encode the ANN title screen as PPU display-list packets

off_ann_title_map:
    .byte >$2085, <$2085, $01, $44  ; Sign upper-left corner
    .byte >$2086, <$2086, $55, $48  ; Sign top edge
    .byte >$209b, <$209b, $01, $49  ; Sign upper-right corner
    .byte >$20a5, <$20a5, $c9, $46  ; Sign left edge
    .byte >$20bb, <$20bb, $c9, $4a  ; Sign right edge

    .byte >$20a6, <$20a6, $15
    .incbin "NSMMAIN.bin", $65fd, $015

    .byte >$20c6, <$20c6, $15
    .incbin "NSMMAIN.bin", $6615, $015

    .byte >$20e6, <$20e6, $15
    .incbin "NSMMAIN.bin", $662d, $015

    .byte >$2106, <$2106, $55, $26  ; Blank logo row
    .byte >$2110, <$2110, $0a
    .incbin "NSMMAIN.bin", $6649, $00a

    .byte >$2126, <$2126, $15
    .incbin "NSMMAIN.bin", $6656, $015

    .byte >$2146, <$2146, $15
    .byte $db, $42, $42, $db, $e3, $db, $e3, $db
    .byte $db, $e3, $26, $db, $e3, $db, $e3, $db
    .byte $e3, $db, $e3, $26, $26

    .byte >$2166, <$2166, $46, $db
    .byte >$216c, <$216c, $0f
    .incbin "NSMMAIN.bin", $668a, $00f

    .byte >$2186, <$2186, $15
    .incbin "NSMMAIN.bin", $669c, $010
    .byte $db, $db, $e3, $26, $26

    .byte >$21a6, <$21a6, $15
    .incbin "NSMMAIN.bin", $66b4, $015

    .byte >$21c5, <$21c5, $17
    .incbin "NSMMAIN.bin", $66cc, $017

    .byte >$21ee, <$21ee, $0e
    .incbin "NSMMAIN.bin", $66e6, $00e

    .byte >$224d, <$224d, $0a
    .incbin "NSMMAIN.bin", $66f7, $00a
    .byte >$228d, <$228d, $0a
    .incbin "NSMMAIN.bin", $6704, $00a
    .byte >$22ed, <$22ed, $04, $1d, $18, $19, $28  ; Top score label
    .byte >$22f7, <$22f7, $01, $00  ; Initial top score

    .byte >$23c9, <$23c9, $01, $d5
    .byte >$23ca, <$23ca, $46, $f5
    .byte >$23d1, <$23d1, $47, $55
    .byte >$23d9, <$23d9, $47, $55
    .byte >$23cc, <$23cc, $43, $55
    .byte >$23d6, <$23d6, $01, $dd
    .byte >$23de, <$23de, $01, $5d
    .byte >$23e2, <$23e2, $04, $55, $aa, $aa, $aa
    .byte >$23ea, <$23ea, $05, $95, $aa, $aa, $aa, $2a  ; Attributes

    .byte $00
off_ann_title_map_end:

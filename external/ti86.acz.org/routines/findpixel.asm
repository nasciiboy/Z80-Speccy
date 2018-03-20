;------------------------------------------------------
;   FIND PIXEL ROUTINES by CLEM <clems@mygale.org>
;
;       Input:  x->b
;               y->c
;
;       Output: hl : byte in LCD memory
;               a  : bitmask for (hl)
;
;       If you need speed, use FindPixel, else
;       use Find_Pixel (shorter).
;
;---------------------- examples ----------------------

PixelOn:    ld bc,$1010
            call Find_Pixel
            or (hl)
            ld (hl),a
            ret

PixelOff:   ld bc,$1010
            call Find_Pixel
            cpl
            and (hl)
            ld (hl),a
            ret

PixelInv:   ld bc,$1010
            call Find_Pixel
            xor (hl)
            ld (hl),a
            ret

PixelTest:  ld bc,$1010
            call Find_Pixel
            and (hl)
            ret

;------------------------------------------------------
;   FIND_PIXEL by CLEM
;
;   121 cycles  27 bytes    Destroyes : none
;------------------------------------------------------

Find_Pixel:
    ld h,63
    ld a,c
    add a,a
    add a,a
    ld l,a
    ld a,b
    rra
    add hl,hl
    rra
    add hl,hl
    rra
    or l
    ld l,a
    ld a,b
    and 7
    cpl
    rlca
    rlca
    rlca
    ld (FP_Bit+1),a
    xor a
FP_Bit:
    set 0,a
    ret

;------------------------------------------------------
;   FINDPIXEL by CLEM
;
;   117 cycles  34 bytes    Destroyes : bc
;------------------------------------------------------

FindPixel:
    ld h,63
    ld a,c
    add a,a
    add a,a
    ld l,a
    ld a,b
    rra
    add hl,hl
    rra
    add hl,hl
    rra
    or l
    ld l,a
    ld a,b
    and 7
    ld bc,FP_Bits
    add a,c
    ld c,a
    adc a,b
    sub c
    ld b,a
    ld a,(bc)
    ret

FP_Bits:    .db $80,$40,$20,$10,$08,$04,$02,$01

;------------------------------------------------------

    +-----------------------------------------+
    |     name : CLEM                         |
    | homepage : http://www.mygale.org/~clems | <-- french
    |   e-mail : mailto:clems@mygale.org      |
    +-----------------------------------------+

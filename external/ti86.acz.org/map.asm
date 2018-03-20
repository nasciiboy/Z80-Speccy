; Map by David Phillips <electrum@tfs.net>
; Example of drawing a screen-sized tilemap for 86 Central

#include "ti86asm.inc"

.org _asm_exec_ram

 call _clrLCD
 call _runindicoff
 
 ld hl,Map
 call DrawMap

PauseLoop:
 call _getky
 jr z,PauseLoop
 call _clrLCD
 ret

;============================================================
; DrawMap -- draws an 8x16 tilemap  [Assembly Coder's Zenith]
;  input: HL = pointer to tilemap to draw
;  total: 34b/91529t (including ret and entire GridPutSprite)
;============================================================
DrawMap:
 ld de,$0000            ; start drawing at (0, 0)
DrawMapL:
 push hl                ; save map pointer
 ld l,(hl)              ; get the current tile
 ld h,0                 ; clear the upper byte
 add hl,hl              ; multiply by 8 (* 2)
 add hl,hl              ; * 4
 add hl,hl              ; * 8
 ld bc,Sprites          ; load the start of the sprites
 add hl,bc              ; add togehter to get correct sprite
 push de                ; save sprite draw location
 call GridPutSprite     ; draw the sprite
 pop de                 ; restore sprite draw location
 pop hl                 ; restore map pointer
 inc hl                 ; go to next tile
 inc e                  ; move location to the right
 bit 4,e                ; if the 5th bit (e = 16), we're done
 jr z,DrawMapL          ; only jump if the row isn't complete
 ld e,0                 ; draw at the left again
 inc d                  ; move location down a row
 bit 3,d                ; check if it's done (e = 8)
 ret nz                 ; return if we're done
 jr DrawMapL            ; jump back to the top of the loop

;===========================================================
; GridPutSprite:                       [routine by Dan Eble]
;  Puts an aligned sprite at (E, D), where HL -> Sprite
;===========================================================
; IN : D  = y (0-7 inclusive)
;      E  = x (0-15 inclusive)
;      HL-> sprite
;
; OUT: AF, BC, DE, HL, IX modified
; Current total : 28b/567t (not counting ret)
;===========================================================
GridPutSprite:
 push hl
 pop ix					; ix-> sprite
 srl d          		; de = 128y+x (16 bytes/row, 8 rows)
 rra
 and $80
 or e           		; add x offset (remember x <= 15)
 ld e,a
 ld hl,$fc00            ; hl-> video ram
 add hl,de              ; hl-> video ram + offset
 ld b,8                 ; initialize loop counter
 ld de,$10              ; initialize line increment
GPS_Loop
 ld a,(ix+0)    		; get byte from sprite
 ld (hl),a      		; put byte on screen
 inc ix         		; move to next byte in sprite
 add hl,de     			; move to next line on screen
 djnz GPS_Loop
 ret


Map:
    .db $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    .db $1,$2,$3,$0,$1,$2,$3,$0,$7,$0,$0,$0,$A,$9,$3,$0
    .db $0,$4,$0,$0,$0,$4,$0,$0,$4,$0,$0,$0,$4,$0,$0,$0
    .db $0,$4,$0,$0,$0,$4,$0,$0,$4,$0,$0,$0,$C,$3,$0,$0
    .db $0,$4,$0,$0,$0,$4,$0,$0,$4,$0,$0,$0,$4,$0,$0,$0
    .db $0,$5,$0,$0,$1,$6,$3,$0,$8,$9,$3,$0,$B,$9,$3,$0
    .db $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    .db $D,$D,$D,$D,$D,$D,$D,$D,$D,$D,$D,$D,$D,$D,$D,$D

Sprites:

Sprite0:
	.db %00000000
	.db %00000000
	.db %00000000
	.db %00000000
	.db %00000000
	.db %00000000
	.db %00000000
	.db %00000000

Sprite1:
	.db %00000000
	.db %01111111
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01111111
	.db %00000000

Sprite2:
	.db %00000000
	.db %11111111
	.db %00000000
	.db %00000000
	.db %00000000
	.db %00000000
	.db %11000011
	.db %01000010

Sprite3:
	.db %00000000
	.db %11111110
	.db %00000010
	.db %00000010
	.db %00000010
	.db %00000010
	.db %11111110
	.db %00000000

Sprite4:
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010

Sprite5:
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01111110
	.db %00000000

Sprite6:
	.db %01000010
	.db %11000011
	.db %00000000
	.db %00000000
	.db %00000000
	.db %00000000
	.db %11111111
	.db %00000000

Sprite7:
	.db %00000000
	.db %01111110
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010
	.db %01000010

Sprite8:
	.db %01000010
	.db %01000011
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01111111
	.db %00000000

Sprite9:
	.db %00000000
	.db %11111111
	.db %00000000
	.db %00000000
	.db %00000000
	.db %00000000
	.db %11111111
	.db %00000000

SpriteA:
	.db %00000000
	.db %01111111
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01000011
	.db %01000010

SpriteB:
	.db %01000010
	.db %01000011
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01111111
	.db %00000000

SpriteC:
	.db %01000010
	.db %01000011
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01000000
	.db %01000011
	.db %01000010

SpriteD:
	.db %11111111
	.db %10000001
	.db %10100101
	.db %10000001
	.db %10000001
	.db %10100101
	.db %10000001
	.db %11111111

.end

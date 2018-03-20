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

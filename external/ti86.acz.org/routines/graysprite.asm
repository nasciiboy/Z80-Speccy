#include "asm86.h"
#include "ti86asm.inc"

.org _asm_exec_ram

 ld ix,Zambian
 ld b,63
 ld c,23
 call PutSprite
 ld a,c
 add a,17
 ld c,a
 call PutSprite
 ret

Zambian:			;Matt's graphic :-)
.db %01110000
.db %01110000
.db %00100100
.db %01111111
.db %10110100
.db %01110000
.db %00101000
.db %01101100

Kelp:
.db %01110000
.db %01110000
.db %00100100
.db %01111111
.db %10110100
.db %01110000
.db %00101000
.db %01101100

;PutSprite
;Input: bc = x,y; ix = 8x8 sprite location: video mem layer, graph mem, layer
;Output: sprite drawn; ix points to next sprite (if your sprites follow
;	   in sequence); hl and and de destroyed

PutSprite:
 ld h,63			;shifted to $fc with add hl,hl
 ld a,c
 add a,a			;a*4
 add a,a
 ld l,a
 add hl,hl			;hl*4 (what was c has been mlt by 16
 add hl,hl
 ld a,b			;a/8
 rra
 rra
 rra
 or l				;add to more significant bytes
 ld l,a
 ld a,7			;use bottom 7 bits for counter
 and b
 ld d,a			;save counter copy in d
 push bc
 push hl
 call copy_sprite
 ld bc,$32			;memory difference
 and a			;reset carry
 pop hl
 sbc hl,bc			;_plotSScreen offset
 call copy_sprite
 pop bc
 ret

copy_sprite:
 ld e,8			;8 rows
ps_loop:
 ld b,d			;get saved bit offset in b
 ld a,(ix)			;get this byte of the sprite in a
 inc ix			;point ix to the next byte of the sprite
 ld c,0
 call bit_shift
 xor (hl)			;change this to or if you want
 ld (hl),a
 inc l
 ld a,(hl)
 xor c			;also changable to or (if you changed the first)
 ld (hl),a
 ld a,15			;add 15 to hl (now ready for next row)
 call add_hl_a
 dec e			;counter (8 rows)
 jr nz,ps_loop
 ret

add_hl_a:			;add hl,a
 add a,l
 ld l,a
 ret nc
 inc h
 ret

bit_shift:			;while(b=<0)
 dec b			; a>>c
 ret m
 srl a
 rr c
 jr bit_shift

.end
.end
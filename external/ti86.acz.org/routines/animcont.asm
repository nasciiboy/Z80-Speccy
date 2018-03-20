;Animation Controller
;Dux Gregis

;Interrupt animation controller installer and calls to insert / delete
; / swap animations, maximum of 8 animations at a time.
;Each animation is a byte containing the # of frames, followed by each
; sprite, which is an 8x8 sprite and a sprite mask; maximum of 16
; frames per animation.
;It currently

;***********************
;***********************
;call loadAnim
;set up animation controller interrupt and animation table
;***********************
;call addAnim
;insert new animation to animation table
;Input = HL points to animation
;Output = (HL) points current sprite frame
;***********************
;call delAnim
;delete animation from table
;Input = HL pointer returned in addAnim
;***********************
;call swapAnim
;exchange animation not in table with one in the table
;Input = HL pointer returned in addAnim; DE = pointer to new animation
;Output = void; same (HL) controls swapped animation
;***********************
;***********************


;the animataion table is a byte containing the current frame, a byte
;containing the # of frames, and 16-bit pointer, in that order


animCounter			equ		$805f
animTable			equ		$8060


;***********************
;install animation controller (to uninstall: <im 1>)
;***********************

loadAnim:

 ld hl,$8100		;create vector 256 byte table at 8100
 ld de,$8101
 ld bc,256
 ld (hl),$80		; pointing to $8080
 ldir

 ld hl,animTable	;clear animation table
 ld de,animTable+1
 ld bc,32
 xor a
 ld (hl),a
 ldir

 ld (animCounter),a	;and clear counter

 ld hl,int			;copy interrupt handler
 ld de,$8080
 ld bc,int_end-int_start
 ldir

 ld a,$81			;point to vector table
 ld i,a

 im 2				;enable our interrupt
 ret


;***********************
;create animation entry of animation at HL
;this will return a pointer to a pointer of the current frame
; in HL; the best thing to do is to store HL to a RAM address and
; then access it like this: <ld hl,(thisAnimation) / call $33> so
; that HL will point to the sprite frame to display
;***********************

addAnim:
 ld a,(hl)			;get # of frames
 and 16				;to prevent crashes
 ld c,a				;save it in C

 ex de,hl
 ld hl,AnimTable	;start search here
 ld b,8				;max # of search iterations

searchAnim:			;search animation table for first open entry
 ld a,(hl)
 and a
 jr z,storeAnim		;store animation entry once space found

 inc l				;HL = next possible entry
 inc l
 inc l
 inc l

 djnz searchAnim

 ld hl,0			;bad return: table full
 ret

storeAnim:
 ld (hl),c			;store # of frames first
 inc l

 ld (hl),a			;clear current frame

 inc de				;set first frame pointer
 ld (hl),e
 inc l
 ld (hl),d

 dec l				;return pointer to pointer in HL
 ret


;***********************
;delete animation at HL
;***********************

delAnim:
 dec l
 dec l
 ld (hl),0
 ret


;***********************
;swap animation at DE into table entry accessed by HL
;useful for changing the direction that an animated sprite is facing
;***********************

swapAnim:
 dec l				;(HL) = # of frames
 dec l

 ex de,hl
 ldi				;copy # of frames & inc pointers
 ex de,hl

 inc l
 ld (hl),0			;clear current frame

 inc l
 ld (hl),e			;copy new pointer
 inc l
 ld (hl),d

 ret				;doesn't return anything



;***********************
;internal interrupt code
;***********************

animate:			;search the animation table and
 ld hl,animTable	; animate all entries
 ld (AnimCounter),a	;clear counter
 ld b,8				;number of entries in the table

animLoop:
 ld a,(hl)			;load the byte of # of frames
 or a				;if # of frames zero
 jr z,animSkip		; no entry
 inc l
 cp (hl)			;check if on last frame
 jr z,resetFrame	; and adjust it if it is

 inc a
 ld (hl),a			;increment current frame byte

 push hl
 call $33			;ld hl,(hl)
 ld de,16
 add hl,de			;point to next frame
 ex de,hl
 pop hl
 inc l
 ld (hl),e			;load pointer to table
 inc l
 ld (hl),d
 inc l
 djnz animLoop
 ret

animSkip:
 dec b				;check if end of loop
 ret z				;if so, done
 inc l				;if not, point to next entry
 inc l
 inc l
 inc l
 jr animLoop		;back to main animation loop

resetFrame:
 ld (hl),0			;reset frame #
 inc l				;point to frame pointer

 add a,a			;A = A * 16
 add a,a
 add a,a
 add a,a
 ld d,0				;DE = A
 ld e,a

 push hl
 call $33			;ld hl,(hl)
 or a				;reset carry
 sbc hl,de			;first frame
 ex de,hl
 pop hl
 ld (hl),e			;load first frame pointer to table
 inc l
 ld (hl),d
 inc l
 djnz animLoop		;keep looping if necessary
 ret


int:

.org $8080

int_start:

 exx				;use shadow registers in int
 ex af,af'

;other interrupt code can go here

 ld a,(animCounter)
 sub $10			;change this to adjust frames per second
 call z,animate

 jp $66				;run normal interrupt handler

int_end:
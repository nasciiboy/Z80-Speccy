;===========================================================
; DoMenu -- Bar menu routine        [Assembly Coders Zenith]
; Clears the screen and displays a table driven bar menu
;  
; written by David Phillips <electrum@tfs.net>
; helped by David Scheltema <scheltem@aaps.k12.mi.us>
; optimizations by CLEM <clems@mygale.org>
;
; input: HL = menu table
; output: chosen table address jumped to
;
; example table:
;  .db 2				; num entries
;  .db "My menu",0		; title text (at the top)
;  .db "First thing",0	; text for each entry
;  .db "Second one",0	; ...
;  .dw Option1			; pointers (labels) to jump
;  .dw Option2			; to for each entry in menu
;
; Note: routine must be jumped to!
;===========================================================
DoMenu:
 push hl					; _clrLCD destroys hl
 call _clrLCD				; clears the screen
 pop hl						; now restore it
 ld c,(hl)					; get number of entries
 inc hl						; move to menu title text
 ld de,$0001				; draw at top, one char right
 ld	(_penCol),de			; set the small font coords
 call _vputs				; print the title text
 ld de,$fc00				; point to video ram
 call DoMenuInv				; invert the top line
 ld b,c						; load num entries for loop
 ld de,$0729				; start printing at middle of second line
DoMenuDTL:
 ld (_penCol),de			; set the font coords
 call _vputs				; print the menu text
 ld a,d						; get the vertical coord
 add a,7					; move to next line
 ld d,a						; save new coord
 djnz DoMenuDTL				; draw all the text
 push hl 					; save pointer
DoMenuFirst:
 ld b,1						; start menu at first entry
DoMenuBar:
 call DoMenuInvBar			; invert it
DoMenuL:
 call $4068					; same as GET_KEY, doesn't destroy bc !!!
 cp K_UP					; did they press up?
 jr z,DoMenuUp				; move menu bar up
 cp K_DOWN					; or was it down?
 jr z,DoMenuDown			; then move the bar down
 cp K_SECOND				; did they hit 2nd?
 jr z,DoMenuSelect			; then they want it
 cp K_ENTER					; some people like enter
 jr nz,DoMenuL				; they're just sitting there, loop again
DoMenuSelect:
 pop hl						; restore the pointer
 ld d,0						; clear upper byte
 ld e,b						; load lower byte with current selection
 dec e						; decrease, starting at 0 instead of 1
 sla e						; multiply by 2, pointers are 16-bit (2 bytes)
 add hl,de					; add to get correct address in the jump table
 ld a,(hl)					; get lower byte of pointer
 inc hl						; next byte
 ld h,(hl)					; get upper byte of pointer
 ld l,a						; complete pointer with lower byte
 jp (hl)					; jump to the address from the table--hl, not (hl)
DoMenuUp:
 call DoMenuInvBar			; invert current selection back to normal
 dec b						; move up
 jr nz,DoMenuBar			; if it's zero, we're at the top
 ld b,c						; so move to the bottom
 jr DoMenuBar				; handle menu bar
DoMenuDown:
 call DoMenuInvBar			; same as up, go back to normal text
 ld a,c						; get current entry for check
 cp b						; at the bottom?
 jr z,DoMenuFirst			; the move to the top
 inc b						; move down
 jr DoMenuBar				; handle menu bar
DoMenuInvBar:
 push hl					; save pointer
 push bc					; save position and entries
 ld h,b						; get position
 ld l,112					; there are 7 lines of 16 bytes each (7*16 = 112)
 call MUL_HL				; do the multiply
 ld de,$fc00				; we need to add to video memory
 add hl,de					; do the add
 ex de,hl					; hl -> de
 call DoMenuInv				; invert the line
 pop bc						; restore position and entries
 pop hl						; restore pointer
 ret						; done inverting
DoMenuInv:
 ld b,7*16					; each row is 16 bytes wide and text is 7 rows high
DoMenuIL:
 ld a,(de)					; get the byte
 cpl						; NOT the byte--flips all the bits
 ld (de),a					; save the new byte
 inc de						; next byte
 djnz DoMenuIL				; loop for all bytes
 ret						; we're done with the invert loop

;=======================================================
; TextView by David Phillips   [Assembly Coder's Zenith]
;
; input: HL = text to display
; format: -must start and end with $ed
;	      -first string must start with a zero-byte
;         -all strings must be at least once char
;          long and be separated with a zero-byte,
;          including the _first_ string
;         -text must have at least 8 strings
;         -max length of a string is 21 chars
;
; example:
;  .db $ed,0					; must start like this
;  .db "Some cool text that",0
;  .db "will be scrolled!",0
;  .db " ",0					; blank line
;  .db "And now the end...",0
;  .db $ed						; must end like this
;=======================================================
TextView:
 res appAutoScroll,(iy+appflags)
 push hl
 call _clrLCD
 pop hl
 inc hl
 inc hl
 ld (TextTop),hl
 ld b,8
 ld d,0
TextViewDL:
 ld a,8
 sub b
 ld e,a
 ld (_curRow),de
 call _puts
 djnz TextViewDL
 ld (TextBottom),hl
TextViewLoop:
 call _getky			; \
 cp K_DOWN				;  \
 jr z,TextViewSUp		;   \
 cp K_UP				;	 >    GET_KEY -- a nice, good speed
 jr z,TextViewSDown 	;   /
 cp K_EXIT				;  /
 jr nz,TextViewLoop		; /
; ld a,%01111110		; \
; out (1),a				;  \
; nop \ nop				;   \
; in a,(1)				;    \
; bit 3,a				;     \
; jr z,TextViewSDown	;	   \
; bit 0,a				;       \ Ports -- if you want it really,
; jr z,TextViewSUp		;       /          really, really fast
; ld a,%00111111		;      /
; out (1),a				;     /
; nop \ nop				;    /
; in a,(1)				;   /
; bit 6,a				;  /
; jr nz,TextViewLoop	; /
 ret
TextViewSUp:
 ld hl,(TextBottom)
 ld a,$ed
 cp (hl)
 jr z,TextViewLoop
 ld hl,$fc00+128
 ld de,$fc00
 ld bc,1024-128
 ldir
 ld hl,$fc00+(128*7)
 ld b,128
 call $437b				; _ldhlz
 ld hl,$0007
 ld (_curRow),hl
 ld hl,(TextBottom)
 call _puts
 xor a
 cp (hl)
 jr nz,TextViewSkipI
 inc hl
TextViewSkipI:
 ld (TextBottom),hl
 ld hl,(TextTop)
 call TextViewPtrI
 ld (TextTop),hl
 jr TextViewLoop
TextViewSDown:
 ld hl,(TextTop)
 dec hl
 dec hl
 ld a,$ed
 cp (hl)
 jr z,TextViewLoop
 ld hl,$ffff-128
 ld de,$ffff
 ld bc,1024-128
 lddr 
 ld hl,$fc00
 ld b,128
 call $437b				; _ldhlz
 call _homeup
 ld hl,(TextTop)
 call TextViewPtrD
 call _puts
 ld hl,(TextTop)
 call TextViewPtrD
 ld (TextTop),hl
 ld hl,(TextBottom)
 call TextViewPtrD
 ld (TextBottom),hl 
 jp TextViewLoop
TextViewPtrD:
 xor a
 ld b,255
 dec hl
 dec hl
 cpdr
 inc hl
 inc hl
 ret
TextViewPtrI:
 xor a
 ld b,255
 cpir
 ret
TextTop = _OP1
TextBottom = _OP1 + 2

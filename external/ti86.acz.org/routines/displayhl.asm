;====================================================================
; DisplayHL:  (idea from SCaBBy/Mardell)    [Assembly Coder's Zenith]
;  Display HL as a 5-digit decimal number with no leading zeros
;  out: AF, HL, BC, DE destroyed
;====================================================================
DisplayHL:
 ld c,'0'  				; save ascii value for zero
 ld de,_OP1+5			; point to end of the buffer
 xor a				; zero terminate string
 ld (de),a				; set last byte to zero
DisplayHLl:
 call UNPACK_HL			; next digit
 dec de				; next position
 add a,c				; convert to ascii
 ld (de),a				; save digit
 ld a,h				; load upper byte
 or l					; check with lower byte for zero
 jr nz,DisplayHLl			; loop
 ex de,hl				; point to buffer
 call _vputs			; print number
 ret					; we're done

; Simple Grayscale demo created by Matthew Johnson
;  Must include BlitzGry.h

;  "86 Central" - Largest TI-86 Asm Programmin Research Site
;  http://www.dogtech.com/cybop/ti86/
; E-mail me! matt2000@gte.net

#include "ti86asm.inc"

.org _asm_exec_ram
		call 	_clrLCD
        call    OpenGray

; When a pixel is set at $FC00 and $CA00, it appears dark (black)
; If the pixel is only set at $FC00 it appears dark grey
; If the pixel is only set at $CA00 it appears light grey
; If the pixel is clear at $FC00 and $CA00 then it appears light 

; First Quarter of Screen

		ld      hl, $FC00
		ld		(hl), $FF
        ld      de, $FC01
        ld      bc, 255
        ldir

		ld      hl, $CA00
		ld		(hl), $FF
        ld      de, $CA01
        ld      bc, 255
        ldir

; Second Quarter of Scree

		ld      hl, $CB00
		ld		(hl), $00
        ld      de, $CB01
        ld      bc, 255
        ldir

		ld      hl, $FD00
		ld		(hl), $FF
        ld      de, $FD01
        ld      bc, 255
        ldir

; Third Quarter of Screen

		ld      hl, $CC00
		ld		(hl), $FF
        ld      de, $CC01
        ld      bc, 255
        ldir

		ld      hl, $FE00
		ld		(hl), $00
        ld      de, $FE01
        ld      bc, 255
        ldir

; Fourth Quarter of Screen

		ld      hl, $CD00
		ld		(hl), $00
        ld      de, $CD01
        ld      bc, 255
        ldir

		ld      hl, $FF00
		ld		(hl), $00
        ld      de, $FF01
        ld      bc, 255
        ldir

getkey:
        ld a,%00111111
        out (1),a
        nop
        nop
        in a,(1)
        bit 6,a
		jr nz, getkey

		call CloseGray

        call    _runindicon
        ret

#include "BlitzGry.h"
.END

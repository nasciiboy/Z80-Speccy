;Russian Peasants' Algorithm
;Dux Gregis

;input= h and l
;output= de is h*l (all reg destroyed but c)

mlt_hl:
 ld de,0		;clear de initially
 ld a,h
 cp l			;check to see which is the greater of h and l
 jr c,mlt_start
 ld h,l
 ld l,a
mlt_start:
 ld b,h
 ld h,d			;b is now smaller of the two, hl is the greater
mlt_loop:
 srl b			;if bit 0 is set, add hl to de
 call c,collect_de
 ret z			;return when b is zero (still set from srl)
 add hl,hl		;shift hl left
 jr mlt_loop

collect_de:		;store addition in de
 ex de,hl
 add hl,de
 ex de,hl
 ret
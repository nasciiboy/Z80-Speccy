; 16 bit signed multiplication routine
;
; HL = BC*DE
;
; Destroys: AF, BC, DE

Mult:
 xor a
 bit 7,b
 jr z,Pos1
 inc a
 ld hl,0
 sbc hl,bc
 ld b,h
 ld c,l
Pos1:
 bit 7,d
 jr z,Pos2
 inc a
 ld hl,0
 or a
 sbc hl,de
 ld d,h
 ld e,l
Pos2:
 push af
 ld hl,0
 ld a,16
MultLoop:
 add hl,hl
 rl e
 rl d
 jr nc,NoAdd
 add hl,bc
NoAdd:
 dec a
 jr nz,MultLoop
 pop af
 res 7,h
 bit 0,a
 ret z
 ex de,hl
 ld hl,0
 or a
 sbc hl,de
 ret 

; 16 bit signed multiplication routine (REALLY LOUSY CODED!!!)
;
; If DE=0, returns with carry flag set.
; If DE<>0, returns with carry cleared and HL = BC/DE
;
; Destroys: AF, BC, DE

Div:
 ld a,d
 or e
 scf
 ret z
 xor a
 bit 7,b
 jr z,Pos3
 inc a
 ld hl,0
 sbc hl,bc
 ld b,h
 ld c,l
Pos3:
 bit 7,d
 jr z,Pos4
 inc a
 ld hl,0
 sbc hl,de
 ld d,h
 ld e,l
Pos4: 
 ld h,b
 ld l,c
 ld bc,0
DivLoop:
 or a
 sbc hl,de
 jr c,FixSign 
 inc bc
 jr DivLoop
FixSign:
 ld h,b
 ld l,c
 or a
 res 7,h
 bit 0,a
 ret z 
 ld hl,0 
 sbc hl,bc
 or a
 ret 

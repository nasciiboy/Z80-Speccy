;General Sound Algorithm
;Dux Gregis

#include "asm86.h"
#include "Ti86asm.inc"

.org _asm_exec_ram

wait:
 call _getkey
 jr z,wait

 ld ix,main		;jp (ix) is the fastest way to jp
 ld c,%111100	;value to toggle link port values with
play:
 ld hl,wav		;hl always points to current wav byte
main:
 ld a,(hl)
 or a
 ret z
 ld e,a
 cpl
 ld d,a		;near even duration
 ld a,i		;to prevent background noise, don't use im 2
loop2:
 ld b,e
loop1:
 djnz loop1		;frequency loop
 xor c
 out (7),a
 dec d
 jp nz,loop2	;duration loop
 ld i,a
 inc hl
 jp (ix)


;zero terminated wav file
;the larger the number (unsigned), the lower the pitch
wav:
.db 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
.db 26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
.db 48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69
.db 70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91
.db 92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109
.db 110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125
.db 126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142
.db 143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
.db 160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176
.db 177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193
.db 194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210
.db 211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227
.db 228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244
.db 245,246,247,248,249,250,251,252,253,254,255,0

.end
.end
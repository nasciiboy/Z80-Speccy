; turn off the calculator (stays in program)

CalcOff:
 ld a,1
 out (3),a
 halt
 ld a,11
 out (3),a        
 res onInterrupt,(iy+onflags)

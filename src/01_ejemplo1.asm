; Pruebas de ensamblador para z80-asm
; Santiago Romero aka NoP/Compiler

        ORG 40000
        LD HL, 16384
        LD A, 162
        LD (HL), A
        LD DE, 16385
        LD BC, 6911
        LDIR
        RET

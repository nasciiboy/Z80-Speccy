  ; Ejemplo de uso de LUT
  ORG 50000

entrada:
  
  CALL Generate_Scanline_Table
  LD B, 191

loop_draw:
  PUSH BC
  
  LD C, 127
  CALL Get_Pixel_Offset_LUT_HR

  LD A, 128
  LD (HL), A

  POP BC
  DJNZ loop_draw

loop:                    ; Bucle para no volver a BASIC y que
  jr loop                ; no se borren la 2 ultimas lineas


;--------------------------------------------------------
; Generar LookUp Table de scanlines en memoria.
; Rutina por Derek M. Smith (2005).
;--------------------------------------------------------

Scanline_Offsets EQU $F900

Generate_Scanline_Table:
   LD DE, $4000
   LD HL, Scanline_Offsets
   LD B, 192

genscan_loop:
   LD (HL), E
   INC L
   LD (HL), D
   INC HL
   
   INC D
   LD A, D
   AND 7
   JR NZ, genscan_nextline
   LD A, E
   ADD A, 32
   LD E, A
   JR C, genscan_nextline
   LD A, D
   SUB 8
   LD D, A
   
genscan_nextline:
   DJNZ genscan_loop
   RET


;-------------------------------------------------------------
; Get_Pixel_Offset_LUT_HR(x,y):
;
; Entrada:   B = Y,  C = X
; Salida:   HL = Direccion de memoria del pixel (x,y)
;            A = Posicion relativa del pixel en el byte
;-------------------------------------------------------------
Get_Pixel_Offset_LUT_HR:
   LD DE, Scanline_Offsets
   LD L, B
   LD H, 0
   ADD HL, HL
   ADD HL, DE
   LD A, (HL)
   INC L
   LD H, (HL)
   LD L, A

   LD A, C
   AND 248
   RRCA
   RRCA
   RRCA
   ADD A, L 
   LD L, A
   LD A, C
   AND 7
   RET

END 50000

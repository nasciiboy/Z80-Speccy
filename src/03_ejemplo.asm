; Programa de ejemplo para mostrar el aspecto de
; un programa típico en ensamblador para PASMO.
; Copia una serie de bytes a la videomemoria con
; instrucciones simples (sin optimizar).
ORG 40000

valor     EQU  1
destino   EQU  18384

  ; Aqui empieza nuestro programa que copia los
  ; 7 bytes desde la etiqueta "datos" hasta la
  ; videomemoria ([16384] en adelante).
  
  LD HL, destino     ; HL = destino (VRAM)
  LD DE, datos       ; DE = origen de los datos
  LD B, 6            ; numero de datos a copiar
  
bucle:               ; etiqueta que usaremos luego
                 
  LD A, (DE)         ; Leemos un dato de [DE]
  ADD A, valor       ; Le sumamos 1 al dato leído
  LD (HL), A         ; Lo grabamos en el destino [HL]
  INC DE             ; Apuntamos al siguiente dato
  INC HL             ; Apuntamos al siguiente destino
  
  DJNZ bucle         ; Equivale a:
                     ; B = B-1
                     ; if (B>0) goto Bucle
  RET

datos DEFB 127, %10101010, 0, 128, $FE, %10000000, 00h

END

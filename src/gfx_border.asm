 ; Cambio del color del borde al pulsar espacio
  ORG 50000
 
  LD B, 6              ; 6 iteraciones, color inicial borde

start:
 
bucle:
  LD A, $7F            ; Semifila B a ESPACIO
  IN A, ($FE)          ; Leemos el puerto
  BIT 0, A             ; Testeamos el bit 0 (ESPACIO)
  JR NZ, bucle         ; Si esta a 1 (no pulsado), esperar
 
  LD A, B              ; A = B
  CALL SetBorder       ; Cambiamos el color del borde
 
suelta_tecla:          ; Ahora esperamos a que se suelte la tecla
  LD A, $7F            ; Semifila B a ESPACIO
  IN A, ($FE)          ; Leemos el puerto
  BIT 0, A             ; Testeamos el bit 0
  JR Z, suelta_tecla   ; Saltamos hasta que se suelte
 
  DJNZ bucle           ; Repetimos "B" veces
  LD B, 7
  JP start             ; Y repetir
 
salir:
  RET
 
;------------------------------------------------------------
; SetBorder: Cambio del color del borde al del registro A
;------------------------------------------------------------
SetBorder:
  OUT (254), A
  RET

  END 50000            ; Ejecucion en 50000

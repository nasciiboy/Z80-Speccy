  ; Cambio del color del borde al pulsar espacio
  ORG 50000

  LD B, 6              ; 6 iteraciones, color inicial borde

bucle:
  LD A, $7F            ; Semifila B a ESPACIO
  IN A, ($FE)          ; Leemos el puerto
  BIT 0, A             ; Testeamos el bit 0 (ESPACIO)
  JR NZ, bucle         ; Si esta a 1 (no pulsado), esperar

  LD A, B              ; A = B
  OUT (254), A         ; Cambiamos el color del borde

suelta_tecla:          ; Ahora esperamos a que se suelte la tecla
  LD A, $7F            ; Semifila B a ESPACIO
  IN A, ($FE)          ; Leemos el puerto
  BIT 0, A             ; Testeamos el bit 0
  JR Z, suelta_tecla   ; Saltamos hasta que se suelte

  djnz bucle           ; Repetimos "B" veces

salir:
  RET

  END 50000



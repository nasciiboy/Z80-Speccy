  ; Lectura de la tecla "P" en un bucle (FORMA 2)
  ORG 50000


bucle:
  LD A, $DF            ; Semifila "P" a "Y"
  IN A, ($FE)          ; Leemos el puerto
  BIT 0, A             ; Testeamos el bit 0
  JR Z, salir          ; Si esta a 0 (pulsado) salir.
  JR bucle             ; Si no (a 1, no pulsado) repetimos

salir:
  RET

  END 50000



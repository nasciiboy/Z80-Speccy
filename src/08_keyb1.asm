  ; Lectura de la tecla "P" en un bucle
  ORG 50000


bucle:
  LD BC, $DFFE         ; Semifila "P" a "Y"
  IN A, (C)            ; Leemos el puerto
  BIT 0, A             ; Testeamos el bit 0
  JR Z, salir          ; Si esta a 0 (pulsado) salir.
  JR bucle             ; Si no (a 1, no pulsado) repetimos

salir:
  RET

  END 50000



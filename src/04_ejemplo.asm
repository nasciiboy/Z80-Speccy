; Ejemplo de LDIR donde copiamos 6144 bytes de la ROM
; a la videomemoria. Digamos que "veremos la ROM" :)
ORG 40000

  LD HL, 0         ; Origen: la ROM
  LD DE, 16384     ; Destino: la VideoRAM
  LD BC, 6144      ; toda la pantalla
  LDIR             ; copiar

RET
  

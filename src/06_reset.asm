  ; Mal uso de la pila: reset
  ORG 50000

  CALL SUMA_A_10
  LD C, B              ; Esta direccion se  introduce en la pila con CALL

bucle:
  jp bucle             ; bucle infinito
  

SUMA_A_10:
  LD DE, $0000
  PUSH DE
  ADD A, 10
  LD B, a
  RET                  ; RET no sacara de la pila lo introducido por CALL
                       ; sino "0000", el valor que hemos pulsado nosotros.



; Ejemplo que muestra el intercambio de registros
; mediante el uso de la pila.
ORG 40000

; Cargamos en DE el valor 12345 y
; realizamos un intercambio de valores
; con BC, mediante la pila:
LD DE, 12345
LD BC, 0

PUSH DE
PUSH BC
POP DE
POP BC

; Volvemos, ahora BC=DE y DE=BC
RET

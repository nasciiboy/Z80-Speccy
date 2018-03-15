; Ejemplo de ISR que gestiona un contador de ticks, minutos y segundos.
 
  ORG 50000
 
  ; Generamos una tabla de 257 valores "$F1" desde $FE00 a $FF00
  LD HL, $FE00                 
  LD A, $F1           
  LD (HL), A                    ; Cargamos $F1 en $FE00 
  LD DE, $FE01                  ; Apuntamos DE a $FE01
  LD BC, 256                    ; Realizamos 256 LDI para copiar $F1
  LDIR                          ; en toda la tabla de vectores de int.

  ; Instalamos la ISR:
  DI
  LD A, 254                     ; Definimos la tabla a partir de $FE00.
  LD I, A
  IM 2                          ; Saltamos a IM2
  EI
 
Bucle_entrada:
  LD A, (clock_changed)
  AND A
  JR Z, Bucle_entrada           ; Si clock_changed no vale 1, no hay
                                ; que imprimir el mensaje


 
  ; Si estamos aqui es que clock_changed = 1... lo reseteamos
  ; e imprimimos por pantalla la información como MM:SS
  XOR A
  LD (clock_changed), A         ; clock_changed = 0
 
  CALL 0DAFh                    ; Llamamos a la rutina de la ROM que
                                ; hace un CLS y pone el cursor en (0,0)
 
  LD A, (minutes)               ; Imprimimos minutos + ":" + segundos
  CALL PrintInteger2Digits
  LD A, ":"
  RST 16
  LD A, (seconds)
  CALL PrintInteger2Digits
 
  JR Bucle_entrada 
 
clock_changed DB 0
ticks         DB 0
seconds       DB 0
minutes       DB 0
pause         DB 0
abs_ticks     DW 0
timer         DW 0
 
;-----------------------------------------------------------------------
; PrintInteger2Digits: Imprime en la pantalla un numero de 1 byte en
;        base 10, pero solo los 2 primeros digitos (0-99).
;        Para ello convierte el valor numerico en una cadena llamando
;        a Byte2ASCII_2Dig y luego llama a RST 16 para imprimir cada
;        caracter por separado.
;
; Entrada: A = valor a "imprimir" en 2 digitos de base 10.
;-----------------------------------------------------------------------
PrintInteger2Digits:
  PUSH AF
  PUSH DE
  CALL Byte2ASCII_Dec2Digits     ; Convertimos A en Cadena Dec 0-99
  LD A, D
  RST 16                         ; Imprimimos primer valor HEX
  LD A, E
  RST 16                         ; Imprimimos segundo valor HEX
 
  POP DE
  POP AF
  RET
 
 
;-----------------------------------------------------------------------
; Byte2ASCII_Dec2Digits: Convierte el valor del registro H en una 
; cadena de texto de max. 2 caracteres (0-99) decimales.
;
; IN:   A = Numero a convertir
; OUT:  DE = 2 bytes con los ASCIIs
;
; Basado en rutina dtoa2d de:
; http://99-bottles-of-beer.net/language-assembler-%28z80%29-813.html
;-----------------------------------------------------------------------
Byte2ASCII_Dec2Digits:
   LD D, '0'                      ; Starting from ASCII '0' 
   DEC D                          ; Because we are inc'ing in the loop
   LD E, 10                       ; Want base 10 please
   AND A                          ; Clear carry flag
 
dtoa2dloop:
   INC D                          ; Increase the number of tens
   SUB E                          ; Take away one unit of ten from A
   JR NC, dtoa2dloop              ; If A still hasn't gone negative, do another
   ADD A, E                       ; Decreased it too much, put it back
   ADD A, '0'                     ; Convert to ASCII
   LD E, A                        ; Stick remainder in E
   RET
 
;-----------------------------------------------------------------------



; Con este ORG $F1F1 nos aseguramos de que la ISR sera ensamblada
; por el ensamblador a partir de esta direccion, que es donde queremos
; que este ubicada para que el salto del procesador sea a la ISR.
; Asi pues, todo lo que siga a este ORG se ensamblara para cargarse
; a partir de la direccion $F1F1 de la RAM.
ORG $F1F1

;-----------------------------------------------------------------------
; Rutina de ISR : incrementa ticks 50 veces por segundo, y el resto
; de las variables de acuerdo al valor de ticks.
;-----------------------------------------------------------------------
CLOCK_ISR_ASM_ROUTINE:
   PUSH AF
   PUSH HL
 
   LD A, (pause)
   OR A
   JR NZ, clock_isr_fin          ; Si pause==1, no continuamos la ISR
 
   LD HL, (abs_ticks)
   INC HL
   LD (abs_ticks), HL            ; Incrementamos abs_ticks (absolutos)
 
   LD HL, (timer)
   DEC HL
   LD (timer), HL                ; Decrementamos timer (ticks absolutos)

   LD A, (ticks)
   INC A
   LD (ticks), A                 ; Incrementamos ticks (50 veces/seg)
 
   CP 50
   JR NZ, clock_isr_fin          ; if ticks < 50,  fin de la ISR
                                 ; si ticks >= 50, cambiar seg:min
   XOR A
   LD (ticks), A                 ; ticks = 0
 
   LD A, 1
   LD (clock_changed), A         ; ha cambiado el numero de segundos
 
   LD A, (seconds)
   INC A
   LD (seconds), A               ; seconds = segundos +1
 
   CP 60
   JR NZ, clock_isr_fin          ; si segundos < 60 -> salir de la ISR
 
   XOR A                         ; si segundos == 60 -> inc minutos
   LD (seconds), A               ; seconds = 0
 
   LD A, (minutes)
   INC A
   LD (minutes), A               ; minutes = minutos + 1
 
   CP 60
   JR NZ, clock_isr_fin          ; si minutos > 60 -> resetear minutos
   XOR A
   LD (minutes), A               ; minutes = 0
 
clock_isr_fin:
   POP HL
   POP AF
 
   EI
   RETI

; Si vamos a colocar mas codigo en el fichero ASM detra de la ISR; este
; sera ensamblado en direcciones a partir de $F1F1 a partir del final
; de la ISR en memoria. Como seguramente no queremos esto, es mejor ubicar
; la ISR con su ORG $F1F1 al final del listado o bien colocar otro ORG
; antes de la siguiente rutina a ensamblar.
 
END 50000

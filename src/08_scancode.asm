; Visualizando los scancodes de las teclas codificadas con "Find_Key"
  ORG 50000

Bucle_entrada:
  CALL Wait_For_Keys_Released

Pedir_Tecla:
  CALL Find_Key                   ; Llamamos a la rutina
  JR NZ, Pedir_Tecla              ; Repetir si la tecla no es valida
  INC D
  JR Z, Pedir_Tecla               ; Repetir si no se pulsa ninguna tecla
  DEC D

  LD A, D                         ; Guardamos en A copia del resultado
  CALL PrintBin                   ; Imprimimos el scancode bin en pantalla

  LD A, D                         ; Guardamos en A copia del resultado
  CALL PrintHex                   ; Imprimimos el scancode hex en pantalla

  CP $21                          ; Comprobamos si A == 21h (enter)
  JR NZ, Bucle_entrada            ; Si no lo es, repetir

  RET                             ; Si es enter, fin del programa


;-----------------------------------------------------------------------
; PrintBin: Imprime en la pantalla un patron para visualizar el valor
; de A en binario, usando 8 pixels "puros" para "1" y punteados para "0"
;
; Entrada: A = valor a "imprimir" en binario
;-----------------------------------------------------------------------
PrintBin:
  PUSH AF
  PUSH HL
  PUSH BC                            ; Preservamos los registros que se usarÃ¡
  LD HL, 20704                       ; Esquina (0,24) de la pantalla
  LD C, A                            ; Guardamos en C copia de A
  LD B, 8                            ; Imprimiremos el estado de los 8 bits

printbin_loop:
  LD A, $FF                          ; Para bit = 1, todo negro
  BIT 7, C                           ; Chequeamos el estado del bit 7
  JR NZ, printbin_es_uno             ; Dejamos A = 255
  LD A, $55                          ; Para bit = 0, punteado/gris
printbin_es_uno:
  LD (HL), A                         ; Lo "imprimimos" (A) y pasamos a la
  INC HL                             ; Siguiente posiciÃ³ en memoria
  RLC C                              ; Rotamos C a la izq para que podamos
                                     ; usar de nuevo el BIT 7 en el bucle
  DJNZ printbin_loop                 ; Repetimos 8 veces

  POP BC
  POP HL
  POP AF
  RET


;-----------------------------------------------------------------------
; PrintHex: Imprime en la pantalla un numero de 1 byte en hexadecimal.
;        Para ello convierte el valor numérico en una cadena llamando
;        a Byte2ASCII_Hex y luego llama a RST 16 para imprimir cada
;        caracter por separado. Imprime un $ delante y ESPACIO detrás.
;
; Entrada: A = valor a "imprimir" en binario
;-----------------------------------------------------------------------
PrintHex:

  PUSH HL
  PUSH AF
  PUSH DE

  LD H, A
  CALL Byte2ASCII_Hex            ; Convertimos A en Cadena HEX
  LD HL, Byte2ASCII_output       ; HL apunta a la cadena

  LD A, "$"
  RST 16                         ; Imprimimos un "$"

  LD A, (HL)
  RST 16                         ; Imprimimos primer valor HEX

  INC HL                         ; Avanzar en la cadena
  LD A, (HL)
  RST 16                         ; Imprimimos segundo valor HEX

  LD A, " "
  RST 16                         ; Imprimimos un espacio

  POP DE
  POP AF
  POP HL
  RET


;-----------------------------------------------------------------------
; Byte2ASCII_Hex: Convierte el valor del registro H en una cadena
; de texto de max. 2 caracteres hexadecimales, para poder imprimirla.
; Rutina adaptada de Num2Hex en http://baze.au.com/misc/z80bits.html .
;
; IN:   H = Numero a convertir
; OUT:  [Byte2ASCII_output] = Espacio de 2 bytes con los ASCIIs
;-----------------------------------------------------------------------
Byte2ASCII_Hex:

   ld de, Byte2ASCII_output
   ld a, h
   call B2AHex_Num1
   ld a, h
   call B2AHex_Num2
   ret

B2AHex_Num1:
   rra
   rra
   rra
   rra

B2AHex_Num2:
   or $F0
   daa
   add a, $A0
   adc a, $40

   ld (de), a
   inc de
   ret

Byte2ASCII_output DB 0, 0
;-----------------------------------------------------------------------


;-----------------------------------------------------------------------
; Esta rutina espera a que no haya ninguna tecla pulsada para volver.
;-----------------------------------------------------------------------
Wait_For_Keys_Released:
 XOR A
 IN A, (254)
 OR 224
 INC A
 JR NZ, Wait_For_Keys_Released
 RET


;-----------------------------------------------------------------------
; Chequea el teclado para detectar la pulsacion de una tecla.
; Devuelve un codigo en el registro D que indica:
;    Bits 0, 1 y 2 de "D": Fila de teclas (puerto) detectada.
;    Bits 3, 4 y 5 de "D": Posicion de la tecla en esa media fila
;
; Flags: ZF desactivado: Mas de una tecla pulsada
;        ZF activado: Tecla correctamente leida
;-----------------------------------------------------------------------
Find_Key:

   LD DE, $FF2F         ; Valor inicial D = "ninguna tecla"
   LD BC, $FEFE         ; Puerto

NXHALF:
   IN A, (C)
   CPL 
   AND $1F
   JR Z, NPRESS         ; Saltar si ninguna tecla pulsada

   INC D                ; Comprobamos si hay mas de 1 tecla pulsada
   RET NZ               ; Si es asi, volver con Z a 0

   LD H, A              ; Calculo del valor de la tecla
   LD A, E

KLOOP:
   SUB 8
   SRL H
   JR NC, KLOOP

   RET NZ               ; Comprobar si mas de una tecla pulsada

   LD D, A              ; Guardar valor de tecla en D

NPRESS:                 ; Comprobar el resto de semifilas
   DEC E
   RLC B
   JR C, NXHALF         ; Repetimos escaneo para otra semifila

   CP A                 ; Ponemos flag a zero
   RET Z                ; Volvemos


END 50000


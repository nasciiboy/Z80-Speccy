  ; Controlando el valor de "valor" con Q y A
  ORG 50000

  LD A, (valor)
  CALL PrintBin                   ; Imprimimos el scancode en pantalla

Bucle_entrada:

  LD BC, 20000                    ; Retardo (bucle 20000 iteraciones)
retardo:
  DEC BC
  LD A, B
  OR C
  JR NZ, retardo                  ; Fin retardo

Comprobar_tecla_mas:
  LD A, (tecla_mas)
  CALL Check_Key
  JR C, mas_no_pulsado            ; Carry = 1, tecla_mas no pulsada

  LD A, (valor)
  INC A
  LD (valor), A                   ; Incrementamos (valor)
  JR Print_Valor

mas_no_pulsado:                   

Comprobar_tecla_menos:
  LD A, (tecla_menos)
  CALL Check_Key
  JR C, menos_no_pulsado          ; Carry = 1, tecla_menos no pulsada

  LD A, (valor)
  DEC A
  LD (valor), A                   ; Decrementamos (valor)
  JR Print_Valor

menos_no_pulsado:

  JR Bucle_entrada                ; Repetimos continuamente hasta que se
                                  ; pulse algo (tecla_mas o tecla_menos)

Print_Valor:
  LD A, (valor)                   ; Guardamos en A copia del resultado
  CALL PrintBin                   ; Imprimimos el scancode en pantalla

  LD A, (valor)                   ; Guardamos en A copia del resultado
  CALL PrintHex                   ; Imprimimos el scancode HEX en pantalla

  JR Bucle_entrada                ; Repetimos

valor        DEFB  0
tecla_mas    DEFB  $25
tecla_menos  DEFB  $26



;-----------------------------------------------------------------------
; Chequea el estado de una tecla concreta, aquella de scancode
; codificado en A (como parametro de entrada).
;
; Devuelve:    CARRY FLAG = 0 -> Tecla pulsada
;              CARRY FLAG = 1 y BC = 0 -> Tecla no pulsada
;-----------------------------------------------------------------------
Check_Key:
   LD C, A          ; Copia de A

   AND 7
   INC A
   LD B, A          ; B = 16 - (num. linea direcció
   SRL C
   SRL C
   SRL C
   LD A, 5
   SUB C
   LD C, A          ; C = (semifila + 1)

   LD A, $FE

CKHiFind:           ; Calcular el octeto de mayor peso del puerto
   RRCA
   DJNZ CKHiFind

   IN A, ($FE)      ; Leemos la semifila

CKNXKey:
   RRA
   DEC C
   JR NZ, CKNXKey   ; Ponemos el bit de tecla en el CF
   
   RET   



;-----------------------------------------------------------------------
; PrintBin: Imprime en la pantalla un patron para visualizar el valor
; de A en binario, usando 8 pixels "puros" para "1" y punteados para "0"
;
; Entrada: A = valor a "imprimir" en binario
;-----------------------------------------------------------------------
PrintBin:
  PUSH AF
  PUSH HL
  PUSH BC                            ; Preservamos los registros que se usará
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
  INC HL                             ; Siguiente posició en memoria
  RLC C                              ; Rotamos C a la izq para que podamos
                                     ; usar de nuevo el BIT 7 en el bucle
  DJNZ printbin_loop                 ; Repetimos 8 veces

  POP BC
  POP HL
  POP AF
  RET


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
; PrintHex: Imprime en la pantalla un numero de 1 byte en hexadecimal.
;        Para ello convierte el valor numÃ©rico en una cadena llamando
;        a Byte2ASCII_Hex y luego llama a RST 16 para imprimir cada
;        caracter por separado. Imprime un $ delante y ESPACIO detrÃ¡s.
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



 END 50000

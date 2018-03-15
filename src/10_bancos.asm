;----------------------------------------------------------------------
; Bancos.asm
;
; Demostracion del uso de bancos / paginación en modo 128K
; pasmo --tapbas 
;----------------------------------------------------------------------

  ORG 32000

  LD HL, 0
  ADD HL, SP                      ; Guardamos el valor actual de SP
  EX DE, HL                       ; lo almacenamos en DE

  LD SP, 24000                    ; Pila fuera de 0xc000-0xffff

  CALL Wait_For_Keys_Released
  LD HL, 0xc000                   ; Nuestro puntero

  ; Ahora paginamos el banco 0 sobre 0xc000 y guardamos un valor
  ; en el primer byte de sus 16K (en la direccion 0xc000):
  LD B, 0
  CALL SetRAMBank                 ; Banco 0

  LD A, 0xAA
  LD (HL), A                      ; (0xc000) = 0xAA

  ; Ahora paginamos el banco 1 sobre 0xc000 y guardamos un valor
  ; en el primer byte de sus 16K (en la direccion 0xc000):
  LD B, 1
  CALL SetRAMBank                 ; Banco 1

  LD A, 0x01
  LD (HL), A                      ; (0xC000) = 0x01

  ; Esperamos una pulsación de teclas antes de empezar:
  CALL Wait_For_Keys_Pressed
  CALL Wait_For_Keys_Released

  ; Ahora vamos a cambiar de nuevo al banco 0, leemos el valor que
  ; hay en 0xc000 y lo representamos en pantalla. Recordemos que
  ; acabamos de escribir 0x01 (00000001) antes de cambiar de banco,
  ; y que en su momento pusimos 0xAA (unos y ceros alternados):
  LD B, 0
  CALL SetRAMBank                 ; Banco 0
  LD A, (HL)                      ; Leemos (0xc000)
  CALL ClearScreen                ; Lo pintamos en pantalla

  ; Esperamos una pulsación de teclas:
  CALL Wait_For_Keys_Pressed
  CALL Wait_For_Keys_Released

  ; Ahora vamos a cambiar de nuevo al banco 1, leemos el valor que
  ; hay en 0xc000 y lo representamos en pantalla. Recordemos que
  ; acabamos de leer 0xA antes de cambiar de banco, y que en su
  ; momento pusimos 0x01:
  LD B, 1
  CALL SetRAMBank                 ; Banco 0
  LD A, (HL)                      ; Leemos (0xc000)
  CALL ClearScreen                ; Lo pintamos en pantalla

  ; Esperamos una pulsación de teclas:
  CALL Wait_For_Keys_Pressed
  CALL Wait_For_Keys_Released

  EX DE, HL                       ; Recuperamos SP para poder volver
  LD SP, HL                       ; a BASIC sin errores
  RET 


;-----------------------------------------------------------------------
; SetRAMBank: Establece un banco de memoria sobre 0xc000
; Entrada: B = banco (0-7) a paginar entre 0xc000-0xffff
;-----------------------------------------------------------------------
SetRAMBank:
   LD A,(0x5b5c)                  ; Valor anterior del puerto
   AND 0xf8                       ; Sólo cambiamos los bits necesarios
   OR B                           ; Elegir banco "B"
   LD BC,0x7ffd
   DI
   LD (0x5b5c),A
   OUT (C),A
   EI
   RET


;-----------------------------------------------------------------------
; ClearScreen: Limpia toda la pantalla con un patrón gráfico dado.
; Entrada: A = valor a "imprimir" en pantalla.
;-----------------------------------------------------------------------
ClearScreen:
   PUSH HL
   PUSH DE
   LD HL, 16384
   LD (HL), A
   LD DE, 16385
   LD BC, 6143
   LDIR
   POP DE
   POP HL
   RET


;-----------------------------------------------------------------------
; Rutinas para esperar la pulsación y liberación de todas las teclas:
;-----------------------------------------------------------------------
Wait_For_Keys_Pressed:
   XOR A                        ; A = 0
   IN A, (254)
   OR 224
   INC A
   JR Z, Wait_For_Keys_Pressed
   RET

Wait_For_Keys_Released:
   XOR A
   IN A, (254)
   OR 224
   INC A
   JR NZ, Wait_For_Keys_Released
   RET

END 32000

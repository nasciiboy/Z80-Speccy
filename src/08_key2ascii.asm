
; Prueba de conversion de Scancode a ASCII

ORG 32768

START:

  CALL Wait_For_Keys_Released

chequear_teclas:
  CALL Find_Key                   ; Llamamos a la rutina
  JR NZ, chequear_teclas          ; Repetir si la tecla no es válida
  INC D
  JR Z, chequear_teclas           ; Repetir si no se pulsó ninguna tecla
  DEC D

  ; En este punto D es un scancode valido 
  call Scancode2Ascii

  ; En este punto A contiene el ASCII del scancode en D
  ; lo imprimimos por pantalla con rst 16.
  rst 16

  CALL Wait_For_Keys_Released

  jr START                        ; vuelta a empezar


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
; Devuelve un código en el registro D que indica:
;
;    Bits 0, 1 y 2 de "D": Fila de teclas (puerto) detectada.
;    Bits 3, 4 y 5 de "D": Posicion de la tecla en esa media fila
;
; Asi, el valor devuelto nos indica la semifila a leer y el bit a testear.
; El registro D valdra 255 ($FF) si no hay ninguna tecla pulsada.
;
; Flags: ZF desactivado: Mas de una tecla pulsada
;        ZF activado: Tecla correctamente leida
;-----------------------------------------------------------------------
Find_Key:
 
   LD DE, $FF2F         ; Valor inicial "ninguna tecla"
   LD BC, $FEFE         ; Puerto
 
NXHALF:
   IN A, (C)
   CPL 
   AND $1F
   JR Z, NPRESS         ; Saltar si ninguna tecla pulsada
   INC D                ; Comprobamos si hay mas de 1 tecla pulsada
   RET NZ               ; Si es asi volver con Z a 0 
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


;-----------------------------------------------------------------------
; Scancode2Ascii: convierte un scancode en un valor ASCII
; IN:  D = scancode de la tecla a analizar
; OUT: A = Codigo ASCII de la tecla
;-----------------------------------------------------------------------
Scancode2Ascii:

   push hl
   push bc

   ld hl,0
   ld bc, TABLA_S2ASCII
   add hl, bc           ; hl apunta al inicio de la tabla

   ; buscamos en la tabla un max de 40 veces por el codigo
   ; le sumamos 40 a HL, leemos el valor de (HL) y ret A
SC2Ascii_1:
   ld a, (hl)           ; leemos un byte de la tabla
   cp "1"               ; Si es "1" fin de la rutina (porque en
                        ; (la tabla habriamos llegado a los ASCIIs)
   jr z, SC2Ascii_Exit  ; (y es condicion de forzado de salida) 
   inc hl               ; incrementamos puntero de HL
   cp d                 ; comparamos si A==D (nuestro scancode)
   jr nz, SC2Ascii_1

SC2Ascii_Found:
   ld bc, 39            ; Sumamos 39(+INC HL=40) para ir a la seccion
   add hl, bc           ; de la tabla con los codigos ASCII
   ld a,(hl)            ; leemos el codigo ASCII de esa tabla

SC2Ascii_Exit:
   pop bc
   pop hl
   ret

   ; 40 scancodes seguidos de sus ASCIIs equivalentes
TABLA_S2ASCII:
   defb $24, $1C, $14, $0C, $04, $03, $0B, $13, $1B, $23
   defb $25, $1D, $15, $0D, $05, $02, $0A, $12, $1A, $22
   defb $26, $1E, $16, $0E, $06, $01, $09, $11, $19, $21
   defb $27, $1F, $17, $0F, $07, $00, $08, $10, $18, $20
   defm "1234567890QWERTYUIOPASDFGHJKLecZXCVBNMys"

END 32768

  ; Ejemplo de estilos de fuente
  ORG 32768

  LD HL, $3D00-256        ; Saltamos los 32 caracteres iniciales
  LD (FONT_CHARSET), HL
  LD A, 1+(7*8)
  LD (FONT_ATTRIB), A

  ;;; Probamos los diferentes estilos: NORMAL
  LD A, FONT_NORMAL
  LD (FONT_STYLE), A
  LD HL, cadena1
  LD A, 4
  LD (FONT_Y), A
  XOR A
  LD (FONT_X), A
  CALL PrintString_8x8

  ;;; Probamos los diferentes estilos: NEGRITA
  LD A, FONT_BOLD
  LD (FONT_STYLE), A
  LD HL, cadena2
  LD A, 6
  LD (FONT_Y), A
  XOR A
  LD (FONT_X), A
  CALL PrintString_8x8

  ;;; Probamos los diferentes estilos: CURSIVA
  LD A, FONT_ITALIC
  LD (FONT_STYLE), A
  LD HL, cadena3
  LD A, 8
  LD (FONT_Y), A
  XOR A
  LD (FONT_X), A
  CALL PrintString_8x8

  ;;; Probamos los diferentes estilos: SUBRAYADO
  LD A, FONT_UNDERSC
  LD (FONT_STYLE), A
  LD HL, cadena4
  LD A, 10
  LD (FONT_Y), A
  XOR A
  LD (FONT_X), A
  CALL PrintString_8x8

loop:
  JR loop

  RET

cadena1 DB "IMPRESION CON ESTILO NORMAL.", 0
cadena2 DB "IMPRESION CON ESTILO NEGRITA.", 0
cadena3 DB "IMPRESION CON ESTILO CURSIVA.", 0
cadena4 DB "IMPRESION CON ESTILO SUBRAYADO.", 0


;-------------------------------------------------------------
FONT_CHARSET   DW    0
FONT_ATTRIB    DB    0
FONT_STYLE     DB    0
FONT_X         DB    0
FONT_Y         DB    0

FONT_NORMAL    EQU   0
FONT_BOLD      EQU   1
FONT_UNDERSC   EQU   2
FONT_ITALIC    EQU   3


;-------------------------------------------------------------
; PrintChar_8x8:
; Imprime un caracter de 8x8 pixeles de un charset usando
; el estilo especificado en FONT_STYLE
;
; Entrada (paso por parametros en memoria):
; -----------------------------------------------------
; FONT_CHARSET = Direccion de memoria del charset.
; FONT_X       = Coordenada X en baja resolucion (0-31)
; FONT_Y       = Coordenada Y en baja resolucion (0-23)
; FONT_ATTRIB  = Atributo a utilizar en la impresion.
; FONT_STYLE   = Estilo a utilizar (0-N).
; Registro A   = ASCII del caracter a dibujar.
;-------------------------------------------------------------
PrintChar_8x8:

   LD BC, (FONT_X)      ; B = Y,  C = X
   EX AF, AF'           ; Nos guardamos el caracter en A'

   ;;; Calculamos las coordenadas destino de pantalla en DE:
   LD A, B
   AND $18
   ADD A, $40
   LD D, A
   LD A, B
   AND 7
   RRCA
   RRCA
   RRCA
   ADD A, C
   LD E, A              ; DE contiene ahora la direccion destino.

   ;;; Calcular posicion origen (array sprites) en HL como:
   ;;;     direccion = base_sprites + (NUM_SPRITE*8)
   EX AF, AF'           ; Recuperamos el caracter a dibujar de A'
   LD BC, (FONT_CHARSET)
   LD H, 0
   LD L, A
   ADD HL, HL
   ADD HL, HL
   ADD HL, HL
   ADD HL, BC         ; HL = BC + HL = FONT_CHARSET + (A * 8)

   EX DE, HL          ; Intercambiamos DE y HL (DE=origen, HL=destino)

   ;;; NUEVO: Verificacion del estilo actual
   LD A, (FONT_STYLE)           ; Obtenemos el estilo actual
   OR A
   JR NZ, pchar8_estilos_on      ; Si es != cero, saltar

   ;;;;;; Estilo NORMAL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   LD B, 8            ; 8 scanlines a dibujar
drawchar_loop_normal:
   LD A, (DE)         ; Tomamos el dato del caracter
   LD (HL), A         ; Establecemos el valor en videomemoria
   INC DE
   INC H
   DJNZ drawchar_loop_normal
   JR pchar8_printattr

pchar8_estilos_on:
   CP FONT_BOLD                 ; ¿Es estilo NEGRITA?
   JR NZ, pchar8_nobold          ; No, saltar

   ;;;;;; Estilo NEGRITA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   LD B, 8            ; 8 scanlines a dibujar
drawchar_loop_bold:
   LD A, (DE)         ; Tomamos el dato del caracter
   LD C, A            ; Creamos copia de A
   RRCA               ; Desplazamos A
   OR C               ; Y agregamos C
   LD (HL), A         ; Establecemos el valor en videomemoria
   INC DE             ; Incrementamos puntero en caracter
   INC H              ; Incrementamos puntero en pantalla (scanline+=1)
   DJNZ drawchar_loop_bold
   JR pchar8_printattr

pchar8_nobold:
   CP FONT_UNDERSC              ; ¿Es estilo SUBRAYADO?
   JR NZ, pchar8_noundersc      ; No, saltar

   ;;;;;; Estilo SUBRAYADO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   LD B, 7            ; 7 scanlines a dibujar normales
drawchar_loop_undersc:
   LD A, (DE)         ; Tomamos el dato del caracter
   LD (HL), A         ; Establecemos el valor en videomemoria
   INC DE
   INC H
   DJNZ drawchar_loop_undersc

   ;;; El octavo scanline, una linea de subrayado
   LD A, 255          ; Ultima linea = subrayado
   LD (HL), A
   INC H              ; Necesario para el SUB A, 8
   JR pchar8_printattr

pchar8_noundersc:
   CP FONT_ITALIC               ; ¿Es estilo ITALICA?
   JR NZ, pchar8_UNKNOWN        ; No, saltar

   ;;;;;; Estilo ITALICA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;;; 3 primeros scanlines, a la derecha,
   LD B, 3
drawchar_loop_italic1:
   LD A, (DE)         ; Tomamos el dato del caracter
   SRA A              ; Desplazamos A a la derecha
   LD (HL), A         ; Establecemos el valor en videomemoria
   INC DE
   INC H
   DJNZ drawchar_loop_italic1

   ;;; 2 siguientes scanlines, sin tocar
   LD B, 2

drawchar_loop_italic2:
   LD A, (DE)         ; Tomamos el dato del caracter
   LD (HL), A         ; Establecemos el valor en videomemoria
   INC DE
   INC H
   DJNZ drawchar_loop_italic2

   LD B, 3
drawchar_loop_italic3:
   ;;; 3 ultimos scanlines, a la izquierda,
   LD A, (DE)         ; Tomamos el dato del caracter
   SLA A              ; Desplazamos A
   LD (HL), A         ; Establecemos el valor en videomemoria
   INC DE
   INC H
   DJNZ drawchar_loop_italic3
   JR pchar8_printattr


pchar8_UNKNOWN:                 ; Estilo desconocido...
   LD B, 8                      ; Lo imprimimos con el normal
   JR drawchar_loop_normal      ; (estilo por defecto)


   ;;; Impresion de los atributos
pchar8_printattr:

   LD A, H            ; Recuperamos el valor inicial de HL
   SUB 8              ; Restando los 8 scanlines avanzados

   ;;; Calcular posicion destino en area de atributos en DE.
                      ; A = H
   RRCA               ; Codigo de Get_Attr_Offset_From_Image
   RRCA
   RRCA
   AND 3
   OR $58
   LD D, A
   LD E, L

   ;;; Escribir el atributo en memoria
   LD A, (FONT_ATTRIB)
   LD (DE), A         ; Escribimos el atributo en memoria
   RET


;-------------------------------------------------------------
; PrintString_8x8:
; Imprime una cadena de texto de un charset de fuente 8x8.
;
; Entrada (paso por parametros en memoria):
; -----------------------------------------------------
; FONT_CHARSET = Direccion de memoria del charset.
; FONT_X       = Coordenada X en baja resolucion (0-31)
; FONT_Y       = Coordenada Y en baja resolucion (0-23)
; FONT_ATTRIB  = Atributo a utilizar en la impresion.
; Registro HL  = Puntero a la cadena de texto a imprimir.
;                Debe acabar en 
;-------------------------------------------------------------
PrintString_8x8:
   
   ;;; Bucle de impresion de caracter
pstring8_loop:
   LD A, (HL)                ; Leemos un caracter de la cadena
   OR A
   RET Z                     ; Si es 0 (fin de cadena) volver
   INC HL                    ; Siguiente caracter en la cadena
   PUSH HL                   ; Salvaguardamos HL
   CALL PrintChar_8x8        ; Imprimimos el caracter
   POP HL                    ; Recuperamos HL

   ;;; Ajustamos coordenadas X e Y
   LD A, (FONT_X)            ; Incrementamos la X
   INC A                     ; pero comprobamos si borde derecho
   CP 31                     ; X > 31?
   JR C, pstring8_noedgex    ; No, se puede guardar el valor

   LD A, (FONT_Y)            ; Cogemos coordenada Y
   CP 23                     ; Si ya es 23, no incrementar
   JR NC, pstring8_noedgey   ; Si es 23, saltar

   INC A                     ; No es 23, cambiar Y
   LD (FONT_Y), A

pstring8_noedgey:
   LD (FONT_Y), A            ; Guardamos la coordenada Y
   XOR A                     ; Y ademas hacemos A = X = 0

pstring8_noedgex
   LD (FONT_X), A
   JR pstring8_loop


END 32768

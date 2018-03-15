  ; Visualizacion del charset de ejemplo
  ORG 32768

  LD H, 0
  LD L, A
  CALL ClearScreenAttrib     ; Borramos la pantalla

  LD HL, charset1-256        ; Saltamos los 32 caracteres iniciales
  LD (FONT_CHARSET), HL
  XOR A
  LD (FONT_X), A
  INC A
  LD (FONT_Y), A             ; Empezamos en (0,1)
  LD A, 6
  LD (FONT_ATTRIB), A        ; Color amarillo sobre negro

  LD C, 32                   ; Empezamos en caracter 32

  ;;; Bucle vertical
  LD E, 4

bucle_y:

  ;;; Bucle horizontal
  LD B, 16                   ; Imprimimos 16 caracteres horiz

bucle_x:
  LD A, (FONT_X)
  INC A
  LD (FONT_X), A              ; X = X + 1

  LD A, C
  PUSH BC
  PUSH DE                     ; Preservamos registros
  CALL PrintChar_8x8          ; Imprimimos el caracter "C"
  POP DE
  POP BC

  INC C                       ; Siguiente caracter
  DJNZ bucle_x                ; Repetir 16 veces

  LD A, (FONT_Y)              ; Siguiente linea:
  INC A
  INC A                       ; Y = Y + 2
  LD (FONT_Y), A
  XOR A
  LD (FONT_X), A              ; X = 0

  DEC E
  JR NZ, bucle_y              ; Repetir 4 veces (16*4=64 caracteres)

loop:
  JR loop
  RET


;-------------------------------------------------------------
FONT_CHARSET   DW    0
FONT_ATTRIB    DB    0
FONT_X         DB    0
FONT_Y         DB    0
;-------------------------------------------------------------


;-------------------------------------------------------------
; PrintChar_8x8:
; Imprime un caracter de 8x8 pixeles de un charset.
;
; Entrada (paso por parametros en memoria):
; -----------------------------------------------------
; FONT_CHARSET = Direccion de memoria del charset.
; FONT_X       = Coordenada X en baja resolucion (0-31)
; FONT_Y       = Coordenada Y en baja resolucion (0-23)
; FONT_ATTRIB  = Atributo a utilizar en la impresion.
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

   ;;; Dibujar 7 scanlines (DE) -> (HL) y bajar scanline (y DE++)
   LD B, 7            ; 7 scanlines a dibujar

drawchar8_loop:
   LD A, (DE)         ; Tomamos el dato del caracter
   LD (HL), A         ; Establecemos el valor en videomemoria
   INC DE             ; Incrementamos puntero en caracter
   INC H              ; Incrementamos puntero en pantalla (scanline+=1)
   DJNZ drawchar8_loop

   ;;; La 8a iteracion, para evitar INC DE + INC H
   LD A, (DE)         ; Tomamos el dato del caracter
   LD (HL), A         ; Establecemos el valor en videomemoria

   LD A, H            ; Recuperamos el valor inicial de HL
   SUB 7              ; Restando los 7 scanlines avanzados

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


;------------------------------------------------------------------
; Limpiar la pantalla con el patron de pixeles y atributos indicado.
; Entrada:  H = atributo, L = patron
;------------------------------------------------------------------
ClearScreenAttrib:
  PUSH DE
  PUSH BC
 
  LD A, H               ; A = el atributo
  EX AF, AF'            ; Nos guardamos el atributo en A'
  LD A, L               ; Cargamos en A el patron
  LD HL, 16384          ; HL = Inicio del area de imagen
  LD (HL), A            ; Escribimos el valor de A en (HL)
  LD DE, 16385          ; Apuntamos DE a 16385
  LD BC, 192*32-1       ; Copiamos 6142 veces (HL) en (DE)
  LDIR
 
  EX AF, AF'            ; Recuperamos A (atributo) de A'
  INC HL                ; Incrementamos HL y DE
  INC DE                ; para entrar en area de atributos
  LD (HL), A            ; Almacenamos el atributo
  LD BC, 24*32-1        ; Ahora copiamos 767 bytes
  LDIR
 
  POP BC
  POP DE
  RET


;-------------------------------------------------------------
; ASM source file created by SevenuP v1.20 - SevenuP (C)
; Copyright 2002-2006 by Jaime Tejedor Gomez, aka Metalbrain
; GRAPHIC DATA:
; Pixel Size:      (  8, 512)
; Char Size:       (  1,  64)
; Sort Priorities: Char line, Y char
; Data Outputted:  Gfx
;-------------------------------------------------------------

charset1:
   DEFB   0,  0,  0,  0,  0,  0,  0,  0,   0, 24, 24, 24, 24,  0, 24,  0
   DEFB   0,108,108, 72,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0
   DEFB   0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0
   DEFB  56,  0, 76, 56,110,196,122,  0,   0, 12, 12,  8,  0,  0,  0,  0
   DEFB   0, 24,  0, 48, 48, 48, 24,  0,   0, 24,  0, 12, 12, 12, 24,  0
   DEFB   0,  0,  0,  0,  0,  0,  0,  0,   0, 24,  0,126,126, 24, 24,  0
   DEFB   0,  0,  0,  0,  0, 12, 12,  8,   0,  0,  0,126,126,  0,  0,  0
   DEFB   0,  0,  0,  0,  0, 56, 56,  0,   0,  0,  6, 12, 24, 48, 96,  0
   DEFB 124,  0,206,214,230,254,124,  0,  28,  0,124, 28, 28, 28, 28,  0
   DEFB 124,  0,198, 28,112,254,254,  0, 124,  0,198, 12,198,254,124,  0
   DEFB  12,  0, 60,108,254,254, 12,  0, 254,  0,192,252, 14,254,252,  0
   DEFB  60,  0,224,252,198,254,124,  0, 254,  0, 14, 28, 28, 56, 56,  0
   DEFB 124,  0,198,124,198,254,124,  0, 124,  0,198,126,  6,126,124,  0
   DEFB   0,  0, 24, 24,  0, 24, 24,  0, 118,  6,192,254,254,198,198,  0
   DEFB 246,  6,192,252,192,254,254,  0,  12, 12, 48, 56, 56, 56, 56,  0
   DEFB 118,  6,192,198,198,254,124,  0, 198,  6,192,198,198,254,124,  0
   DEFB   0, 24,  0, 24, 24, 24, 24,  0, 124,  0,198,254,254,198,198,  0
   DEFB 252,  0,198,252,198,254,252,  0, 124,  0,198,192,198,254,124,  0
   DEFB 252,  0,198,198,198,254,252,  0, 254,  0,192,252,192,254,254,  0
   DEFB 254,  0,224,252,224,224,224,  0, 124,  0,192,206,198,254,124,  0
   DEFB 198,  0,198,254,254,198,198,  0,  56,  0, 56, 56, 56, 56, 56,  0
   DEFB   6,  0,  6,  6,198,254,124,  0, 198,  0,220,248,252,206,198,  0
   DEFB 224,  0,224,224,224,254,254,  0, 198,  0,254,254,214,198,198,  0
   DEFB 198,  0,246,254,222,206,198,  0, 124,  0,198,198,198,254,124,  0
   DEFB 252,  0,198,254,252,192,192,  0, 124,  0,198,198,198,252,122,  0
   DEFB 252,  0,198,254,252,206,198,  0, 126,  0,224,124,  6,254,252,  0
   DEFB 254,  0, 56, 56, 56, 56, 56,  0, 198,  0,198,198,198,254,124,  0
   DEFB 198,  0,198,198,238,124, 56,  0, 198,  0,198,198,214,254,108,  0
   DEFB 198,  0,124, 56,124,238,198,  0, 198,  0,238,124, 56, 56, 56,  0
   DEFB 254,  0, 28, 56,112,254,254,  0,  60,102,219,133,133,219,102, 60
   DEFB   0,  0, 96, 48, 24, 12,  6,  0,  24,  0, 24, 48, 96,102, 60,  0
   DEFB  60,  0, 70, 12, 24,  0, 24,  0,   0,  0,  0,  0,  0,  0,  0,126


END 32768

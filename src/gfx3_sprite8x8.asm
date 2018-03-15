  ; Impresion de un sprite 8x8
  ORG 32768

DS_SPRITES  EQU  50000
DS_ATTRIBS  EQU  50002
DS_COORD_X  EQU  50004
DS_COORD_Y  EQU  50005
DS_NUMSPR   EQU  50006

  CALL ClearScreen_Pattern

  ; Establecemos los parametros de entrada a la rutina
  ; Los 2 primeros se pueden establecer una unica vez 
  LD HL, cara_gfx
  LD (DS_SPRITES), HL
  LD HL, cara_attrib
  LD (DS_ATTRIBS), HL
  LD A, 15
  LD (DS_COORD_X), A
  LD A, 8
  LD (DS_COORD_Y), A
  XOR A
  LD (DS_NUMSPR), A

  CALL DrawSprite_8x8_LD

loop:
  JR loop

  RET


; SevenuP (C) Copyright 2002-2006 by Jaime Tejedor Gomez, aka Metalbrain

;GRAPHIC DATA:
;Pixel Size:      (  8,   8) - (1,   1)
;Sort Priorities: Char line

cara_gfx:  
  DEFB  28, 62,107,127, 93, 99, 62, 28

cara_attrib:
  DEFB  56


;-----------------------------------------------------------------------
; ClearScreen_Pattern
; Limpia la pantalla con patrones de pixeles alternados
;-----------------------------------------------------------------------
ClearScreen_Pattern:

   LD B, 191                   ; Numero de lineas a rellenar

cs_line_loop:
   LD C, 0
   LD A, B
   LD B, A
   CALL $22B1                  ; ROM (Pixel-Address)

   LD A, B
   AND 1
   JR Z, cs_es_par

   LD A, 170
   JR cs_pintar

cs_es_par:
   LD A, 85

cs_pintar:
   LD D, B                     ; Salvar el contador del bucle
   LD B, 32                    ; Imprimir 32 bytes

cs_x_loop:
   LD (HL), A
   INC HL
   DJNZ cs_x_loop

   LD B, D                     ; Recuperamos el contador externo
   DJNZ cs_line_loop           ; Repetimos 192 veces
   RET

;-------------------------------------------------------------
; DrawSprite_8x8_LD:
; Imprime un sprite de 8x8 pixeles con o sin atributos.
;
; Entrada (paso por parametros en memoria):
; Direccion   Parametro
; 50000       Direccion de la tabla de Sprites
; 50002       Direccion de la tabla de Atribs  (0=no atributos)
; 50004       Coordenada X en baja resolucion
; 50005       Coordenada Y en baja resolucion
; 50006       Numero de sprite a dibujar (0-N) 
;-------------------------------------------------------------
DrawSprite_8x8_LD:

   ; Guardamos en BC la pareja (x,y) -> B=COORD_Y y C=COORD_X
   LD BC, (DS_COORD_X)

   ;;; Calculamos las coordenadas destino de pantalla en DE:
   LD A, B
   AND $18
   ADD A, $40
   LD D, A           ; Ya tenemos la parte alta calculada (010TT000)
   LD A, B           ; Ahora calculamos la parte baja
   AND 7
   RRCA
   RRCA
   RRCA              ; A = NNN00000b
   ADD A, C          ; Sumamos COLUMNA -> A = NNNCCCCCb
   LD E, A           ; Lo cargamos en la parte baja de la direccion
                     ; DE contiene ahora la direccion destino.

   ;;; Calcular posicion origen (array sprites) en HL como:
   ;;;     direccion = base_sprites + (NUM_SPRITE*8)
  
   LD BC, (DS_SPRITES)
   LD A, (DS_NUMSPR)
   LD H, 0
   LD L, A           ; HL = DS_NUMSPR
   ADD HL, HL        ; HL = HL * 2
   ADD HL, HL        ; HL = HL * 4
   ADD HL, HL        ; HL = HL * 8 = DS_NUMSPR * 8
   ADD HL, BC        ; HL = BC + HL = DS_SPRITES + (DS_NUMSPR * 8)
                     ; HL contiene la direccion de inicio en el sprite

   EX DE, HL         ; Intercambiamos DE y HL (DE=origen, HL=destino)

   ;;; Dibujar 8 scanlines (DE) -> (HL) y bajar scanline
   ;;; Incrementar scanline del sprite (DE)

   LD B, 8          ; 8 scanlines -> 8 iteraciones
 
drawsp8x8_loopLD:
   LD A, (DE)       ; Tomamos el dato del sprite
   LD (HL), A       ; Establecemos el valor en videomemoria
   INC DE           ; Incrementamos puntero en sprite
   INC H            ; Incrementamos puntero en pantalla (scanline+=1)
   DJNZ drawsp8x8_loopLD

   ;;; En este punto, los 8 scanlines del sprite estan dibujados.
   LD A, H
   SUB 8              ; Recuperamos la posicion de memoria del 
   LD B, A            ; scanline inicial donde empezamos a dibujar
   LD C, L            ; BC = HL - 8

   ;;; Considerar el dibujado de los atributos (Si DS_ATTRIBS=0 -> RET)
   LD HL, (DS_ATTRIBS)

   XOR A              ; A = 0
   ADD A, H           ; A = 0 + H = H
   RET Z              ; Si H = 0, volver (no dibujar atributos)

   ;;; Calcular posicion destino en area de atributos en DE.
   LD A, B            ; Codigo de Get_Attr_Offset_From_Image
   RRCA               ; Obtenemos dir de atributo a partir de
   RRCA               ; dir de zona de imagen.
   RRCA               ; Nos evita volver a obtener X e Y
   AND 3              ; y hacer el calculo completo de la 
   OR $58             ; direccion en zona de atributos
   LD D, A
   LD E, C            ; DE tiene el offset del attr de HL

   LD A, (DS_NUMSPR)  ; Cogemos el numero de sprite a dibujar
   LD C, A
   LD B, 0
   ADD HL, BC         ; HL = HL+DS_NUMSPR = Origen de atributo

   ;;; Copiar (HL) en (DE) -> Copiar atributo de sprite a pantalla
   LD A, (HL)
   LD (DE), A         ; Mas rapido que LDI (7+7 vs 16 t-estados)
   RET                ; porque no necesitamos incrementar HL y DE 

END 32768

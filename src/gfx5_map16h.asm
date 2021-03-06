  ; Ejemplo impresion mapa de 16x16
  ORG 32768

  CALL ClearScreen_Pattern        ; Imprimimos patron de fondo

  LD HL, sokoban1_gfx
  LD (DM_SPRITES), HL
  LD HL, sokoban1_attr
  LD (DM_ATTRIBS), HL
  LD HL, sokoban_LEVEL1
  LD (DM_MAP), HL
  LD A, 16
  LD (DM_WIDTH), A
  LD A, 12
  LD (DM_HEIGHT), A
  XOR A
  LD (DM_COORD_X), A
  LD (DM_COORD_Y), A              ; Establecemos valores llamada
  CALL DrawMap_16x16              ; Imprimir pantalla de mapa

loop:
  JR loop


;-------------------------------------------------------------
DM_SPRITES  EQU  50020
DM_ATTRIBS  EQU  50022
DM_MAP      EQU  50024
DM_COORD_X  EQU  50026
DM_COORD_Y  EQU  50027
DM_WIDTH    EQU  50028
DM_HEIGHT   EQU  50029



;---------------------------------------------------------------
; DrawMap_16x16:
; Imprime una pantalla de tiles de 16x16 pixeles.
;
; Entrada (paso por parametros en memoria):
; Direccion             Parametro
; --------------------------------------------------------------
; DM_SPRITES (2 bytes)  Direccion de la tabla de tiles.
; DM_ATTRIBS (2 bytes)  Direccion de la tabla de atributos.
; DM_MAP     (2 bytes)  Direccion de la pantalla en memoria.
; DM_COORD_X (1 byte)   Coordenada X-Inicial en baja resolucion.
; DM_COORD_Y (1 byte)   Coordenada Y-Inicial en baja resolucion.
; DM_WIDTH   (1 byte)   Ancho del mapa en tiles
; DM_HEIGHT  (1 byte)   Alto del mapa en tiles
;---------------------------------------------------------------
DrawMap_16x16:
 
   ;;;;;; Impresion de la parte grafica de los tiles ;;;;;;
   LD IX, (DM_MAP)           ; IX apunta al mapa 
   LD A, (DM_HEIGHT)
   LD B, A                   ; B = ALTO_EN_TILES (para bucle altura)

drawm16_yloop:
   PUSH BC                   ; Guardamos el valor de B

   LD A, (DM_HEIGHT)         ; A = ALTO_EN_TILES
   SUB B                     ; A = ALTO - iteracion_bucle = Y actual
   RLCA                      ; A = Y * 2

   ;;; Calculamos la direccion destino en pantalla como
   ;;; DIR_PANT = DIRECCION(X_INICIAL, Y_INICIAL + Y*2)
   LD BC, (DM_COORD_X)       ; B = DB_COORD_Y y C = DB_COORD_X
   ADD A, B
   LD B, A
   LD A, B
   AND $18
   ADD A, $40
   LD H, A
   LD A, B
   AND 7
   RRCA
   RRCA
   RRCA
   ADD A, C
   LD L, A                   ; HL = DIR_PANTALLA(X_INICIAL,Y_INICIAL+Y*2)

   LD A, (DM_WIDTH)
   LD B, A                   ; B = ANCHO_EN_TILES

drawm16_xloop:
   PUSH BC                   ; Nos guardamos el contador del bucle

   LD A, (IX+0)              ; Leemos un byte del mapa   
   INC IX                    ; Apuntamos al siguiente byte del mapa

   CP 255                    ; Bloque especial a saltar: no se dibuja
   JP Z, drawm16_next

   LD B, A
   EX AF, AF'                ; Nos guardamos una copia del bloque en A'
   LD A, B

   ;;; Calcular posicion origen (array sprites) en HL como:
   ;;;     direccion = base_sprites + (NUM_SPRITE*32)
   EX DE, HL                 ; Intercambiamos DE y HL (DE=destino)
   LD BC, (DM_SPRITES)
   LD L, 0
   SRL A
   RR L
   RRA
   RR L
   RRA
   RR L
   LD H, A
   ADD HL, BC                ; HL = BC + HL = DM_SPRITES + (DM_NUMSPR * 32)
   EX DE, HL                 ; Intercambiamos DE y HL (DE=origen, HL=destino)

   PUSH HL                   ; Guardamos el puntero a pantalla recien calculado
   PUSH HL

   ;;; Impresion de los primeros 2 bloques horizontales del tile
 
   LD A, (DE)                ; Bloque 1: Leemos dato del sprite
   LD (HL), A                ; Copiamos dato a pantalla
   INC DE                    ; Incrementar puntero en sprite
   INC L                     ; Incrementar puntero en pantalla
   LD A, (DE)                ; Bloque 2: Leemos dato del sprite
   LD (HL), A                ; Copiamos dato a pantalla
   INC DE                    ; Incrementar puntero en sprite
   INC H                     ; Hay que sumar 256 para ir al siguiente scanline
   DEC L                     ; pero hay que restar el INC L que hicimos.

   LD A, (DE)                ; Repetir 7 veces mas
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
 
   ; Avanzamos HL 1 scanline (codigo de incremento de HL en 1 scanline)
   ; desde el septimo scanline de la fila Y+1 al primero de la Y+2
   LD A, L
   ADD A, 31
   LD L, A
   JR C, drawm16_nofix_abajop
   LD A, H
   SUB 8
   LD H, A
drawm16_nofix_abajop:
 
   ;;; Impresion de los segundos 2 bloques horizontales:
   LD A, (DE)                ; Bloque 1: Leemos dato del sprite
   LD (HL), A                ; Copiamos dato a pantalla
   INC DE                    ; Incrementar puntero en sprite
   INC L                     ; Incrementar puntero en pantalla
   LD A, (DE)                ; Bloque 2: Leemos dato del sprite
   LD (HL), A                ; Copiamos dato a pantalla
   INC DE                    ; Incrementar puntero en sprite
   INC H                     ; Hay que sumar 256 para ir al siguiente scanline
   DEC L                     ; pero hay que restar el INC L que hicimos.

   LD A, (DE)                ; Repetir 7 veces mas
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A
   INC DE
   INC H
   DEC L

   LD A, (DE)
   LD (HL), A
   INC DE
   INC L
   LD A, (DE)
   LD (HL), A

   ;;; En este punto, los 16 scanlines del tile estan dibujados.

   ;;;;;; Impresion de la parte de atributos del tile ;;;;;;

   POP HL                    ; Recuperar puntero a inicio de tile

   ;;; Calcular posicion destino en area de atributos en DE.
   LD A, H                   ; Codigo de Get_Attr_Offset_From_Image
   RRCA
   RRCA
   RRCA
   AND 3
   OR $58
   LD D, A
   LD E, L                   ; DE tiene el offset del attr de HL

   LD HL, (DM_ATTRIBS)
   EX AF, AF'                ; Recuperamos el bloque del mapa desde A'
   LD C, A
   LD B, 0
   ADD HL, BC
   ADD HL, BC
   ADD HL, BC
   ADD HL, BC                ; HL = HL+HL=(DM_NUMSPR*4) = Origen de atributo
 
   LDI
   LDI                       ; Imprimimos la primeras fila de atributos
 
   ;;; Avance diferencial a la siguiente linea de atributos
   LD A, E                   ; A = E
   ADD A, 30                 ; Sumamos A = A + 30 mas los 2 INCs de LDI.
   LD E, A                   ; Guardamos en E (E = E+30 + 2 por LDI=E+32)
   JR NC, drawm16_att_noinc
   INC D
drawm16_att_noinc:
   LDI
   LDI                       ; Imprimimos la segunda fila de atributos

   POP HL                    ; Recuperamos el puntero al inicio

drawm16_next:
   INC L                     ; Avanzamos al siguiente tile en pantalla
   INC L                     ; horizontalmente

   POP BC                    ; Recuperamos el contador para el bucle
   DEC B                     ; DJNZ se sale de rango, hay que usar DEC+JP
   JP NZ, drawm16_xloop

   ;;; En este punto, hemos dibujado ANCHO tiles en pantalla (1 fila)
   POP BC
   DEC B                     ; Bucle vertical
   JP NZ, drawm16_yloop

   RET


;--------------------------------------------------------------------
; ClearScreen_Pattern
; Limpia la pantalla con patrones de pixeles alternados
;--------------------------------------------------------------------
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
 


;-----------------------------------------------------------------------
; Level 1 from Sokoban:
;-----------------------------------------------------------------------
sokoban_LEVEL1: 
  DEFB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
  DEFB 255,255,255,255,255,255,2,3,1,4,255,255,255,255,255,255
  DEFB 255,255,255,255,1,2,3,0,0,5,4,255,255,255,255,255
  DEFB 255,255,255,255,4,0,6,6,0,0,5,255,255,255,255,255
  DEFB 255,255,255,255,5,0,0,6,0,0,4,255,255,255,255,255
  DEFB 255,255,255,255,4,0,0,0,0,0,5,255,255,255,255,255
  DEFB 255,255,255,255,5,2,3,0,0,2,3,255,255,255,255,255
  DEFB 255,255,255,255,255,255,1,0,0,0,4,255,255,255,255,255
  DEFB 255,255,255,255,255,255,4,7,7,7,5,255,255,255,255,255
  DEFB 255,255,255,255,255,255,5,2,3,2,3,255,255,255,255,255
  DEFB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
  DEFB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255


;-----------------------------------------------------------------------
; ASM source file created by SevenuP v1.20 
; SevenuP (C) Copyright 2002-2006 by Jaime Tejedor Gomez, aka Metalbrain
; Pixel Size:      ( 16, 128) -   Char Size:       (  2,  16)
; Sort Priorities: X char, Char line, Y char
; Data Outputted:  Gfx / Attr
;-----------------------------------------------------------------------

sokoban1_gfx:
  DEFB   0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0
  DEFB   0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0
  DEFB 127,252,193, 86,152,  2,180,170, 173, 86,153,254,194,170,255,254
  DEFB   0,  0,102,102, 51, 50,153,152, 204,204,102,102, 51, 50,  0,  0
  DEFB 127,102,205, 76,151, 24,205, 50, 151,102,205, 76,151, 24,205, 50
  DEFB 131,102,153, 76,173, 24,181, 50, 153,102,195, 76,127, 24,  0,  0
  DEFB 255,252,255,134,255, 50,255, 90, 255,106,255, 50,255,134,255,254
  DEFB 255,254,255,254,255,254,255,250, 255,242,253,166,255,252,  0,  0
  DEFB 127,252,205,134,151, 50,205,106, 151, 90,205, 50,151,134,205,254
  DEFB 195,254,153,254,173,254,181,250, 153,242,195,166,127,252,  0,  0
  DEFB 255,254,255,254,255,254,255,254, 255,254,255,254,191,254,255,254
  DEFB 255,134,191, 50,255,106,191, 90, 159, 50,207,134,127,252,  0,  0
  DEFB   0,  0,127,254, 95,250, 96,  6, 111,182,111,118, 96,230,109,214
  DEFB 107,182,103,  6,110,246,109,246,  96,  6, 95,250,127,254,  0,  0
  DEFB   0,  0,123,222,123,222, 96,  6,  96,  6,  0,  0, 96,  6, 96,  6
  DEFB  96,  6, 96,  6,  0,  0, 96,  6,  96,  6,123,222,123,222,  0,  0

sokoban1_attr:
  DEFB   0,  0,  0,  0,  5,  5, 70, 70, 5, 70,  5, 70, 69, 71, 69, 71
  DEFB   5, 69, 69, 71, 69, 69, 71, 71, 2, 66, 66, 67,  6, 70, 70, 71


END 32768

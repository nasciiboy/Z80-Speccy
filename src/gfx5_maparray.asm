  ; Ejemplo impresion mapa de 16x16 desde array global
  ORG 32768

  LD HL, sokoban1_gfx
  LD (DM_SPRITES), HL
  LD HL, sokoban1_attr
  LD (DM_ATTRIBS), HL
  LD HL, mapa_ejemplo
  LD (DM_MAP), HL
  LD A, ANCHO_PANTALLA
  LD (DM_WIDTH), A
  LD A, ALTO_PANTALLA
  LD (DM_HEIGHT), A
  XOR A  
  LD (DM_COORD_X), A
  LD (DM_COORD_Y), A   
  LD (DM_MAPX), A            ; Establecemos MAPX, MAPY iniciales
  LD (DM_MAPY), A

redraw:
  CALL DrawMap_16x16_Map     ; Imprimir pantalla de mapa

bucle:
  CALL LEER_TECLADO          ; Leemos el estado de O, P, Q, A

  BIT 0, A                   ; Modificamos MAPX y MAPY segun OPQA
  JR Z, nopulsada_q
  CALL Map_Dec_Y
  JR redraw
nopulsada_q:
  BIT 1, A
  JR Z, nopulsada_a
  CALL Map_Inc_Y
  JR redraw
nopulsada_a:
  BIT 2, A
  JR Z, nopulsada_p
  CALL Map_Inc_X
  JR redraw
nopulsada_p:
  BIT 3, A
  JR Z, nopulsada_o
  CALL Map_Dec_X
  JR redraw
nopulsada_o:
  JR bucle

loop:
  JR loop


;-------------------------------------------------------------
; LEER_TECLADO: Lee el estado de O, P, Q, A, y devuelve
; en A el estado de las teclas (1=pulsada, 0=no pulsada).
; El byte está codificado tal que:
;
; BITS            3    2     1   0
; SIGNIFICADO   LEFT RIGHT DOWN  UP
;-------------------------------------------------------------
LEER_TECLADO:
  LD D, 0
  LD BC, $FBFE
  IN A, (C)
  BIT 0, A                   ; Leemos la tecla Q
  JR NZ, Control_no_up       ; No pulsada, no cambiamos nada en D
  SET 0, D                   ; Pulsada, ponemos a 1 el bit 0
Control_no_up:
 
  LD BC, $FDFE
  IN A, (C)
  BIT 0, A                   ; Leemos la tecla A
  JR NZ, Control_no_down     ; No pulsada, no cambianos nada en D
  SET 1, D                   ; Pulsada, ponemos a 1 el bit 1
Control_no_down:
 
  LD BC, $DFFE
  IN A, (C)
  BIT 0, A                   ; Leemos la tecla P
  JR NZ, Control_no_right    ; No pulsada
  SET 2, D                   ; Pulsada, ponemos a 1 el bit 2
Control_no_right:
                             ; BC ya vale $DFFE, (O y P en misma fila)
  BIT 1, A                   ; Tecla O
  JR NZ, Control_no_left
  SET 3, D
Control_no_left:
 
  LD A, D                    ; Devolvemos en A el estado de las teclas
  RET


;-------------------------------------------------------------
DM_SPRITES  EQU  50020
DM_ATTRIBS  EQU  50022
DM_MAP      EQU  50024
DM_COORD_X  EQU  50026
DM_COORD_Y  EQU  50027
DM_WIDTH    EQU  50028
DM_HEIGHT   EQU  50029
DM_MAPX     EQU  50030
DM_MAPY     EQU  50032

;-------------------------------------------------------------
; Algunos valores hardcodeados para el ejemplo, en la rutina
; final se puede utilizar DM_WIDTH y DM_HEIGHT.
;-------------------------------------------------------------
ANCHO_MAPA_TILES       EQU   32
ALTO_MAPA_TILES        EQU   24
ANCHO_PANTALLA         EQU   14
ALTO_PANTALLA          EQU   11

;;; Rutina de la ROM del Spectrum, en otros sistemas 
;;; sustituir por una rutina especifica de multiplicacion
MULT_HL_POR_DE         EQU   $30A9


;---------------------------------------------------------------
; DrawMap_16x16_Map:
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
; DM_MAPX    (2 bytes)  Coordenada X en mapa.
; DM_MAPY    (2 bytes)  Coordenada Y en mapa.
;---------------------------------------------------------------
DrawMap_16x16_Map:
 
   LD IX, (DM_MAP)           ; IX apunta al mapa 

   ;;; NUEVO: Posicionamos el puntero de mapa en posicion inicial.
   LD HL, (DM_MAPY)
   LD DE, ANCHO_MAPA_TILES
   CALL MULT_HL_POR_DE       ; HL = (ANCHO_MAPA * MAPA_Y)
   LD BC, (DM_MAPX)
   ADD HL, BC                ; HL = MAPA_X + (ANCHO_MAPA * MAPA_Y)
   EX DE, HL
   ADD IX, DE                ; IX = Inicio_Mapa + HL
   ;;; FIN NUEVO

   LD A, (DM_HEIGHT)
   LD B, A                   ; B = ALTO_EN_TILES (para bucle altura)

drawmg16_yloop:
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

drawmg16_xloop:
   PUSH BC                   ; Nos guardamos el contador del bucle

   LD A, (IX+0)              ; Leemos un byte del mapa   
   INC IX                    ; Apuntamos al siguiente byte del mapa

   CP 255                    ; Bloque especial a saltar: no se dibuja
   JP Z, drawmg16_next

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

   LD B, 8
drawmg16_loop1:
 
   LD A, (DE)                ; Bloque 1: Leemos dato del sprite
   LD (HL), A                ; Copiamos dato a pantalla
   INC DE                    ; Incrementar puntero en sprite
   INC L                     ; Incrementar puntero en pantalla
   LD A, (DE)                ; Bloque 2: Leemos dato del sprite
   LD (HL), A                ; Copiamos dato a pantalla
   INC DE                    ; Incrementar puntero en sprite
   INC H                     ; Hay que sumar 256 para ir al siguiente scanline
   DEC L                     ; pero hay que restar el INC L que hicimos.
   DJNZ drawmg16_loop1
   INC L                     ; Decrementar el ultimo incrementado en el bucle
 
   ; Avanzamos HL 1 scanline (codigo de incremento de HL en 1 scanline)
   ; desde el septimo scanline de la fila Y+1 al primero de la Y+2
   LD A, L
   ADD A, 31
   LD L, A
   JR C, drawmg16_nofix_abajop
   LD A, H
   SUB 8
   LD H, A
drawmg16_nofix_abajop:
 
   ;;; Impresion de los segundos 2 bloques horizontales:
   LD B, 8
drawmg16_loop2:
   LD A, (DE)                ; Bloque 1: Leemos dato del sprite
   LD (HL), A                ; Copiamos dato a pantalla
   INC DE                    ; Incrementar puntero en sprite
   INC L                     ; Incrementar puntero en pantalla
   LD A, (DE)                ; Bloque 2: Leemos dato del sprite
   LD (HL), A                ; Copiamos dato a pantalla
   INC DE                    ; Incrementar puntero en sprite
   INC H                     ; Hay que sumar 256 para ir al siguiente scanline
   DEC L                     ; pero hay que restar el INC L que hicimos.
   DJNZ drawmg16_loop2

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
   JR NC, drawmg16_att_noinc
   INC D
drawmg16_att_noinc:
   LDI
   LDI                       ; Imprimimos la segunda fila de atributos

   POP HL                    ; Recuperamos el puntero al inicio

drawmg16_next:
   INC L                     ; Avanzamos al siguiente tile en pantalla
   INC L                     ; horizontalmente

   POP BC                    ; Recuperamos el contador para el bucle
   DEC B                     ; DJNZ se sale de rango, hay que usar DEC+JP
   JP NZ, drawmg16_xloop

   ;;; NUEVO: Incrementar puntero de mapa a siguiente linea
   LD BC, ANCHO_MAPA_TILES - ANCHO_PANTALLA
   ADD IX, BC
   ;;; FIN NUEVO

   ;;; En este punto, hemos dibujado ANCHO tiles en pantalla (1 fila)
   POP BC
   DEC B                     ; Bucle vertical
   JP NZ, drawmg16_yloop

   RET



;-------------------------------------------------------------
; Incrementar la variable DM_MAPX para scrollear a la derecha.
;-------------------------------------------------------------
Map_Inc_X:
  LD HL, (DM_MAPX)

  ;;; Comparacion 16 bits de HL y (ANCHO_MAPA-ANCHO_PANTALLA)
  LD A, H
  CP (ANCHO_MAPA_TILES-ANCHO_PANTALLA) / 256
  RET NZ
  LD A, L
  CP (ANCHO_MAPA_TILES-ANCHO_PANTALLA) % 256
  RET Z

  INC HL                     ; No eran iguales, podemos incrementar.
  LD (DM_MAPX), HL
  RET

;-------------------------------------------------------------
; Incrementar la variable DM_MAPY para scrollear hacia abajo.
;-------------------------------------------------------------
Map_Inc_Y:
  LD HL, (DM_MAPY)

  ;;; Comparacion 16 bits de HL y (ALTO_MAPA-ALTO_PANTALLA)
  LD A, H
  CP (ALTO_MAPA_TILES-ALTO_PANTALLA) / 256
  RET NZ
  LD A, L
  CP (ALTO_MAPA_TILES-ALTO_PANTALLA) % 256
  RET Z

  INC HL                     ; No eran iguales, podemos incrementar.
  LD (DM_MAPY), HL
  RET

;-------------------------------------------------------------
; Decrementar la variable DM_MAPX para scrollear a la izq.
;-------------------------------------------------------------
Map_Dec_X:
  LD HL, (DM_MAPX)
  LD A, H
  AND A
  JR NZ, mapdecx_doit        ; Verificamos que DM_MAPX no sea 0
  LD A, L
  AND A
  RET Z
mapdecx_doit:
  DEC HL
  LD (DM_MAPX), HL           ; No es cero, podemos decrementar
  RET

;-------------------------------------------------------------
; Decrementar la variable DM_MAPY para scrollear hacia arriba.
;-------------------------------------------------------------
Map_Dec_Y:
  LD HL, (DM_MAPY)
  LD A, H
  AND A
  JR NZ, mapdecy_doit        ; Verificamos que DM_MAPX no sea 0
  LD A, L
  AND A
  RET Z
mapdecy_doit:
  DEC HL
  LD (DM_MAPY), HL           ; No es cero, podemos decrementar
  RET


;-----------------------------------------------------------------------
mapa_ejemplo: 
  DEFB 1,2,1,1,2,1,2,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  DEFB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,7,7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,2,3,2,3,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,1
  DEFB 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,7,7,0,0,0,1
  DEFB 1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,7,7,7,0,0,1
  DEFB 1,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,5,0,0,0,0,0,0,2,3,2,3,2,0,1
  DEFB 1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,4,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,5,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,5,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,4,2,3,2,3,0,0,0,0,2,3,2,3,2,3,2,3,4,2,3,2,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,2,3,2,3,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,0,0,6,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,0,6,6,6,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,0,2,3,2,3,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,0,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,0,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,0,0,0,1
  DEFB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,2,3,2,3,2,3,2,3,0,0,1
  DEFB 1,0,2,3,2,2,2,3,2,3,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DEFB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1


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

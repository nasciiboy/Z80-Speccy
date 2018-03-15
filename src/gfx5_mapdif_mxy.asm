  ; Ejemplo impresion mapa de 16x16 codificacion mixta y
  ; XY agrupados en el mismo byte (nibble alto=X, bajo=Y)

  ORG 32768

  ;;; Borramos la pantalla (graficos y atributos)
  XOR A
  CALL ClearScreen
  XOR A
  CALL ClearAttributes

  ;;; Establecer valores de llamada:
  LD HL, sokoban1_gfx
  LD (DM_SPRITES), HL
  LD HL, sokoban1_attr
  LD (DM_ATTRIBS), HL
  LD HL, sokoban_LEVEL1_codif_mixta_XY
  LD (DM_MAP), HL
  LD A, 16
  LD (DM_WIDTH), A
  LD A, 12
  LD (DM_HEIGHT), A
  XOR A
  LD (DM_COORD_X), A
  LD (DM_COORD_Y), A

  ;;; Impresion de pantalla por codificacion mixta XY
  CALL DrawMap_16x16_Cod_Mixta_XY

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

DS_SPRITES  EQU  50000
DS_ATTRIBS  EQU  50002
DS_COORD_X  EQU  50004
DS_COORD_Y  EQU  50005
DS_NUMSPR   EQU  50006


;---------------------------------------------------------------
; DrawMap_16x16_Cod_Mixta_XY: (X e Y codificados en mismo byte)
; Imprime una pantalla de tiles de 16x16 pixeles.
;
; Entrada (paso por parametros en memoria):
; Direccion             Parametro
; --------------------------------------------------------------
; DM_*  = Variables de MAPA
; DS_*  = Variables de SPRITE
;---------------------------------------------------------------
DrawMap_16x16_Cod_Mixta_XY:

   XOR A                     ; Opcode de "NOP"
   LD (drawm16cmxy_dir1), A  ; Almacenar en la posicion de las labels
   LD (drawm16cmxy_dir2), A

   LD HL, (DM_SPRITES)
   LD (DS_SPRITES), HL       ; Establecer tileset (graficos)
   LD HL, (DM_ATTRIBS)
   LD (DS_ATTRIBS), HL       ; Establecer tileset (atributos)
   LD BC, (DM_COORD_X)       ; B = Y_INICIO, C = X_INICIO
   LD IX, (DM_MAP)           ; DE apunta al mapa 

   LD DE, DS_COORD_Y         ; DE apunta a la coordenada Y
   LD HL, DS_COORD_X         ; HL apunta a la coordenada X

drawm16cmxy_read:
   LD A, (IX+0)              ; Leemos el valor de COORDENADAS
   INC IX                    ; Apuntamos al siguiente byte del mapa

drawm16cmxy_loop:
   CP 255                    ; Bloque especial fin de pantalla
   RET Z                     ; En ese caso, salir

   PUSH AF
   AND %11110000             ; Nos quedamos con la parte alta (COORD_X)
   RRCA                      ; Pasamos parte alta a parte baja
   RRCA                      ; con 4 desplazamientos
   RRCA
   RRCA                      ; Ya podemos sumar
   ADD A, C                  ; A = (X_INICIO + COORD_X_TILE)
   RLCA                      ; A = (X_INICIO + COORD_X_TILE) * 2
   LD (HL), A                ; Establecemos COORD_X a imprimir tile

   POP AF
   AND %00001111             ; Nos quedamos con la parte baja (COORD_Y)

   ADD A, B                  ; A = (Y_INICIO + COORD_Y_TILE)
   RLCA                      ; A = (Y_INICIO + COORD_Y_TILE)
   LD (DE), A                ; Establecemos COORD_Y a imprimir tile

   ;;; Bucle impresion vertical de los N tiles del scanline
drawm16cmxy_tileloop:
   LD A, (IX+0)              ; Leemos el valor del TILE de pantalla
   INC IX                    ; Incrementamos puntero

   CP 255
   JR Z, drawm16cmxy_read    ; Si es fin de tile codificado, fin bucle

   CP 254
   JR Z, drawm16cmxy_switch  ; Codigo 254 -> cambiar a codif. vertical

   LD (DS_NUMSPR), A         ; Establecemos el TILE
   EXX                       ; Preservar todos los registros en shadows
   CALL DrawSprite_16x16_LD  ; Imprimir el tile con los parametros
   EXX                       ; Recuperar valores de los registros

drawm16cmxy_dir1:            ; Etiqueta con la direccion del NOP
   NOP                       ; NOP->INC COORD_X,  EX DE,HL->INC COORD_Y
   
   INC (HL)
   INC (HL)                  ; COORD = COORD + 2

drawm16cmxy_dir2:            ; Etiqueta con la direccion del NOP
   NOP                       ; NOP->INC COORD_X,  EX DE,HL->INC COORD_Y

   JR drawm16cmxy_tileloop   ; Repetimos hasta encontrar el 255

drawm16cmxy_switch:
   ;;; Cambio de codificacion de horizontal a vertical:
   LD A, $EB                 ; Opcode de EX DE, HL
   LD (drawm16cmxy_dir1), A    ; Ahora se hace el EX DE, HL y por lo tanto
   LD (drawm16cmxy_dir2), A    ; INC (HL) incrementa COORD_Y en vez de X
   JR drawm16cmxy_read


;-----------------------------------------------------------------------
; Level 1 from Sokoban:
;-----------------------------------------------------------------------
sokoban_LEVEL1_codif_mixta_XY:
 ; Flag codificacion: -m
 ; Resultado: 60 Bytes
 DB 97 , 2 , 3 , 1 , 4 , 255 , 104 , 4 , 7 , 7 , 7 , 255
 DB 105 , 5 , 2 , 3 , 2 , 255 , 82 , 2 , 3 , 255 , 99 , 6
 DB 6 , 255 , 86 , 2 , 3 , 255 , 146 , 5 , 255 , 116 , 6 , 255
 DB 150 , 2 , 255 , 103 , 1 , 254 , 162 , 4 , 5 , 4 , 5 , 3
 DB 4 , 5 , 3 , 255 , 66 , 1 , 4 , 5 , 4 , 5 , 255 , 255


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


;-----------------------------------------------------------------------
; Limpiar la pantalla con el patron de pixeles indicado.
; Entrada:  A = patron a utilizar
;-----------------------------------------------------------------------
ClearScreen:
  LD HL, 16384          ; HL = Inicio del area de imagen
  LD (HL), A            ; Escribimos el valor de A en (HL)
  LD DE, 16385          ; Apuntamos DE a 16385
  LD BC, 192*32-1       ; Copiamos 6142 veces (HL) en (DE)
  LDIR
  RET
 
;-------------------------------------------------------------------------
; Establecer los colores de la pantalla con el byte de atributos indicado.
; Entrada:  A = atributo a utilizar
;-------------------------------------------------------------------------
ClearAttributes:
 
  LD HL, 22528          ; HL = Inicio del area de atributos
  LD (HL), A            ; Escribimos el patron A en (HL)
  LD DE, 22529          ; Apuntamos DE a 22529
  LD BC, 24*32-1        ; Copiamos 767 veces (HL) en (DE)
  LDIR                  ; e incrementamos HL y DL. Restamos 1
                        ; porque ya hemos escrito en 22528.
  RET    


;-------------------------------------------------------------
; DrawSprite_16x16_LD:
; Imprime un sprite de 16x16 pixeles con o sin atributos.
;
; Entrada (paso por parametros en memoria):
; Direccion   Parametro
; 50000       Direccion de la tabla de Sprites
; 50002       Direccion de la tabla de Atribs  (0=no atributos)
; 50004       Coordenada X en baja resolucion
; 50005       Coordenada Y en baja resolucion
; 50006       Numero de sprite a dibujar (0-N) 
;-------------------------------------------------------------
DrawSprite_16x16_LD:
 
   ; Guardamos en BC la pareja (x,y) -> B=COORD_Y y C=COORD_X
   LD BC, (DS_COORD_X)
 
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
   LD E, A
 
   PUSH DE           ; Lo guardamos para luego, lo usaremos para
                     ; calcular la direccion del atributo
 
   ;;; Calcular posicion origen (array sprites) en HL como:
   ;;;     direccion = base_sprites + (NUM_SPRITE*32)
   ;;; Multiplicamos con desplazamientos, ver los comentarios.
   LD BC, (DS_SPRITES)
   LD A, (DS_NUMSPR)
   LD L, 0           ; AL = DS_NUMSPR*256
   SRL A             ; Desplazamos a la derecha para dividir por dos
   RR L              ; AL = DS_NUMSPR*128
   RRA               ; Rotamos, ya que el bit que salio de L al CF fue 0
   RR L              ; AL = DS_NUMSPR*64
   RRA               ; Rotamos, ya que el bit que salio de L al CF fue 0
   RR L              ; AL = DS_NUMSPR*32
   LD H, A           ; HL = DS_NUMSPR*32
   ADD HL, BC        ; HL = BC + HL = DS_SPRITES + (DS_NUMSPR * 32)
                     ; HL contiene la direccion de inicio en el sprite
 
   EX DE, HL         ; Intercambiamos DE y HL (DE=origen, HL=destino)
 
   ;;; Repetir 8 veces (primeros 2 bloques horizontales):
   LD B, 8
 
drawsp16x16_loop1:
   LD A, (DE)         ; Bloque 1: Leemos dato del sprite
   LD (HL), A         ; Copiamos dato a pantalla
   INC DE             ; Incrementar puntero en sprite
   INC L              ; Incrementar puntero en pantalla
 
   LD A, (DE)         ; Bloque 2: Leemos dato del sprite
   LD (HL), A         ; Copiamos dato a pantalla
   INC DE             ; Incrementar puntero en sprite
 
   INC H              ; Hay que sumar 256 para ir al siguiente scanline
   DEC L              ; pero hay que restar el INC L que hicimos.
   DJNZ drawsp16x16_loop1
 
   ; Avanzamos HL 1 scanline (codigo de incremento de HL en 1 scanline)
   ; desde el septimo scanline de la fila Y+1 al primero de la Y+2
 
   ;;;INC H           ; No hay que hacer INC H, lo hizo en el bucle
   ;;;LD A, H         ; No hay que hacer esta prueba, sabemos que
   ;;;AND 7           ; no hay salto (es un cambio de bloque)
   ;;;JR NZ, drawsp16_nofix_abajop
   LD A, L
   ADD A, 32
   LD L, A
   JR C, drawsp16_nofix_abajop
   LD A, H
   SUB 8
   LD H, A
 
drawsp16_nofix_abajop:
 
   ;;; Repetir 8 veces (segundos 2 bloques horizontales):
   LD B, 8
 
drawsp16x16_loop2:
   LD A, (DE)         ; Bloque 1: Leemos dato del sprite
   LD (HL), A         ; Copiamos dato a pantalla
   INC DE             ; Incrementar puntero en sprite
   INC L              ; Incrementar puntero en pantalla
 
   LD A, (DE)         ; Bloque 2: Leemos dato del sprite
   LD (HL), A         ; Copiamos dato a pantalla
   INC DE             ; Incrementar puntero en sprite
 
   INC H              ; Hay que sumar 256 para ir al siguiente scanline
   DEC L              ; pero hay que restar el INC L que hicimos.
   DJNZ drawsp16x16_loop2
 
   ;;; En este punto, los 16 scanlines del sprite estan dibujados.
 
   POP BC             ; Recuperamos el offset del primer scanline
 
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
   ADD HL, BC         ; HL = HL+DS_NUMSPR
   ADD HL, BC         ; HL = HL+DS_NUMSPR*2
   ADD HL, BC         ; HL = HL+DS_NUMSPR*3
   ADD HL, BC         ; HL = HL+HL=(DS_NUMSPR*4) = Origen de atributo
 
   LDI
   LDI                ; Imprimimos las 2 primeras filas de atributo
 
   ;;; Avance diferencial a la siguiente linea de atributos
   LD A, E            ; A = L
   ADD A, 30          ; Sumamos A = A + 30 mas los 2 INCs de LDI.
   LD E, A            ; Guardamos en L (L = L+30 + 2 por LDI=L+32)
   JR NC, drawsp16x16_attrab_noinc
   INC D
drawsp16x16_attrab_noinc:
   LDI
   LDI
   RET                ; porque no necesitamos incrementar HL y DE 
END 32768

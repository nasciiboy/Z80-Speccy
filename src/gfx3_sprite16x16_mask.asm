  ; Sprite 16x16 con mascara
  ORG 32768

DS_SPRITES  EQU  50000
DS_ATTRIBS  EQU  50002
DS_COORD_X  EQU  50004
DS_COORD_Y  EQU  50005
DS_NUMSPR   EQU  50006

  CALL ClearScreen_Pattern

  ; Establecemos los parametros de entrada a la rutina
  ; Los 2 primeros se pueden establecer una unica vez 
  LD HL, bicho_gfx
  LD (DS_SPRITES), HL
  LD HL, bicho_attrib
  LD (DS_ATTRIBS), HL
  LD A, 15
  LD (DS_COORD_X), A
  LD A, 8
  LD (DS_COORD_Y), A
  LD A, 0
  LD (DS_NUMSPR), A

  CALL DrawSprite_16x16_MASK

loop:
  JR loop

  RET


;-----------------------------------------------------------------------
;ASM source file created by SevenuP v1.20
;SevenuP (C) Copyright 2002-2006 by Jaime Tejedor Gomez, aka Metalbrain
;GRAPHIC DATA:
;Pixel Size:      ( 16,  64)
;Char Size:       (  2,   8)
;Sort Priorities: Mask, X char, Char line, Y char
;Data Outputted:  Gfx+Attr
;Mask:            Yes, before graphic
;-----------------------------------------------------------------------
bicho_gfx:
 DEFB 247,  8,127,128,251,  4,191, 64, 255,  0,255,  0,248,  7, 31,224
 DEFB 240, 15, 15, 80,240, 15, 15, 80, 240, 15, 15,240,248,  7, 31,224
 DEFB 255,  0,255,  0,254,  1,191, 64, 255,  0,223, 32,253,  2,255,  0
 DEFB 151,104,233, 22,143,112,241, 14, 199, 56,227, 28,255,  0,255,  0
 DEFB 251,  4,191, 64,255,  0,255,  0, 248,  7, 31,224,240, 15, 15, 80
 DEFB 240, 15, 15, 80,240, 15, 15,240, 248,  7, 31,224,255,  0,255,  0
 DEFB 255,  0,255,  0,254,  1,191, 64, 255,  0,255,  0,253,  2,223, 32
 DEFB 247,  8,255,  0,241, 14,143,112, 248,  7,135,120,255,  0,255,  0
 DEFB 253,  2,223, 32,255,  0,255,  0, 252,  3, 15,240,248,  7,  7,168
 DEFB 248,  7,  7,168,248,  7,  7,248, 252,  3, 15,240,255,  0,255,  0
 DEFB 255,  0,255,  0,254,  1,191, 64, 255,  0,255,  0,254,  1,191, 64
 DEFB 255,  0,255,  0,253,  2, 31,224, 250,  5, 15,240,255,  0,255,  0
 DEFB 254,  1,239, 16,253,  2,223, 32, 255,  0,255,  0,252,  3, 15,240
 DEFB 248,  7,  7,168,248,  7,  7,168, 248,  7,  7,248,252,  3, 15,240
 DEFB 255,  0,255,  0,254,  1,191, 64, 255,  0,223, 32,253,  2,255,  0
 DEFB 151,104,233, 22,143,112,241, 14, 199, 56,227, 28,255,  0,255,  0

bicho_attrib:
 DEFB 70, 71, 67,  3, 70, 71, 67,  3, 70, 71,  3, 67, 70, 71,  3, 67

 ;;; Version en monocolor de los atributos:
 ;;;DEFB 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56


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
; DrawSprite_16x16_MASK:
; Imprime un sprite de 16x16 pixeles + mascara con o sin atributos.
;
; Entrada (paso por parametros en memoria):
; Direccion   Parametro
; 50000       Direccion de la tabla de Sprites
; 50002       Direccion de la tabla de Atribs  (0=no atributos)
; 50004       Coordenada X en baja resolucion
; 50005       Coordenada Y en baja resolucion
; 50006       Numero de sprite a dibujar (0-N) 
;-------------------------------------------------------------
DrawSprite_16x16_MASK:

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
   ;;;     direccion = base_sprites + (NUM_SPRITE*64)
   LD BC, (DS_SPRITES)
   LD A, (DS_NUMSPR)
   LD L, 0           ; AL = DS_NUMSPR*256
   SRL A             ; Desplazamos a la derecha para dividir por dos
   RR L              ; AL = DS_NUMSPR*128
   RRA               ; Rotamos, ya que el bit que salio de L al CF fue 0
   RR L              ; AL = DS_NUMSPR*64
   LD H, A           ; HL = DS_NUMSPR*64
   ADD HL, BC        ; HL = BC + HL = DS_SPRITES + (DS_NUMSPR * 64)
                     ; HL contiene la direccion de inicio en el sprite

   EX DE, HL         ; Intercambiamos DE y HL para el OR

   ;;; Dibujar 8 scanlines (DE) -> (HL) + bajar scanline y avanzar en SPR
   LD B, 8

drawspr16m_loop1:
   LD A, (DE)       ; Obtenemos un byte del sprite (el byte de mascara)
   AND (HL)         ; A = A AND (HL)
   LD C, A          ; Nos guardamos el valor del AND
   INC DE           ; Avanzamos al siguiente byte (el dato grafico)
   LD A, (DE)       ; Obtenemos el byte grafico
   OR C             ; A = A OR C = A OR (MASK AND FONDO)
   LD (HL), A       ; Imprimimos el dato tras aplicar operaciones logicas
   INC DE           ; Avanzamos al siguiente dato del sprite
   INC L            ; Avanzamos al segundo bloque en pantalla

   LD A, (DE)       ; Obtenemos un byte del sprite (el byte de mascara)
   AND (HL)         ; A = A AND (HL)
   LD C, A          ; Nos guardamos el valor del AND
   INC DE           ; Avanzamos al siguiente byte (el dato grafico)
   LD A, (DE)       ; Obtenemos el byte grafico
   OR C             ; A = A OR C = A OR (MASK AND FONDO)
   LD (HL), A       ; Imprimimos el dato tras aplicar operaciones logicas
   INC DE           ; Avanzamos al siguiente dato del sprite

   DEC L            ; Volvemos atras del valor que incrementamos
   INC H            ; Incrementamos puntero en pantalla (siguiente scanline)
   DJNZ drawspr16m_loop1

   ; Avanzamos HL 1 scanline (codigo de incremento de HL en 1 scanline)
   ; desde el septimo scanline de la fila Y+1 al primero de la Y+2
 
   ;;;INC H           ; No hay que hacer INC D, lo hizo en el bucle
   ;;;LD A, H
   ;;;AND 7
   ;;;JR NZ, drawsp16m_nofix_abajop
   LD A, L
   ADD A, 32
   LD L, A
   JR C, drawsp16m_nofix_abajop
   LD A, H
   SUB 8
   LD H, A
drawsp16m_nofix_abajop:

   ;;; Repetir 8 veces (segundos 2 bloques horizontales):
   LD B, 8

drawspr16m_loop2:
   LD A, (DE)       ; Obtenemos un byte del sprite (el byte de mascara)
   AND (HL)         ; A = A AND (HL)
   LD C, A          ; Nos guardamos el valor del AND
   INC DE           ; Avanzamos al siguiente byte (el dato grafico)
   LD A, (DE)       ; Obtenemos el byte grafico
   OR C             ; A = A OR C = A OR (MASK AND FONDO)
   LD (HL), A       ; Imprimimos el dato tras aplicar operaciones logicas
   INC DE           ; Avanzamos al siguiente dato del sprite
   INC L            ; Avanzamos al segundo bloque en pantalla

   LD A, (DE)       ; Obtenemos un byte del sprite (el byte de mascara)
   AND (HL)         ; A = A AND (HL)
   LD C, A          ; Nos guardamos el valor del AND
   INC DE           ; Avanzamos al siguiente byte (el dato grafico)
   LD A, (DE)       ; Obtenemos el byte grafico
   OR C             ; A = A OR C = A OR (MASK AND FONDO)
   LD (HL), A       ; Imprimimos el dato tras aplicar operaciones logicas
   INC DE           ; Avanzamos al siguiente dato del sprite

   DEC L            ; Volvemos atras del valor que incrementamos
   INC H            ; Incrementamos puntero en pantalla (siguiente scanline)
   DJNZ drawspr16m_loop2


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
   JR NC, drawsp16m_attrab_noinc
   INC D
drawsp16m_attrab_noinc:
   LDI
   LDI
   RET                ; porque no necesitamos incrementar HL y DE 


END 32768

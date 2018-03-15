  ; Ejemplo de gestion de texto
  ORG 32768

  LD HL, $3D00-256        ; Saltamos los 32 caracteres iniciales
  CALL Font_Set_Charset

  LD A, 1+(7*8)
  Call Font_Set_Attrib

  ;;; Probamos los diferentes estilos: NORMAL
  LD A, FONT_NORMAL
  CALL Font_Set_Style
  LD HL, cadena1
  LD B, 4
  LD C, 0
  CALL Font_Set_XY
  CALL PrintString_8x8_Format

loop: 
  JR loop
  RET

cadena1 DB "SALTO DE", FONT_LF, "LINEA ", FONT_SET_X, 4, FONT_SET_Y, 9
        DB "IR A (4,9) ", FONT_SET_INK, 2, "ROJO "
        DB FONT_SET_INK, 0, "NEGRO", FONT_CRLF, FONT_LF
        DB "CRLF+LF ", FONT_SET_STYLE, FONT_UNDERSC, "ESTILO SUBRAYADO"
        DB FONT_EOS


;-------------------------------------------------------------
FONT_CHARSET     DW    $3D00-256
FONT_ATTRIB      DB    56
FONT_STYLE       DB    0
FONT_X           DB    0
FONT_Y           DB    0
FONT_SCRWIDTH    EQU   32
FONT_SCRHEIGHT   EQU   24

FONT_NORMAL      EQU   0
FONT_BOLD        EQU   1
FONT_UNDERSC     EQU   2
FONT_ITALIC      EQU   3

FONT_EOS            EQU 0
FONT_SET_STYLE      EQU 1
FONT_SET_X          EQU 2
FONT_SET_Y          EQU 3
FONT_SET_INK        EQU 4
FONT_SET_PAPER      EQU 5
FONT_SET_ATTRIB     EQU 6
FONT_SET_BRIGHT     EQU 7
FONT_SET_FLASH      EQU 8
FONT_XXXXXX         EQU 9       ; Libre para ampliaciones
FONT_LF             EQU 10
FONT_CRLF           EQU 11
FONT_BLANK          EQU 12
FONT_CR             EQU 13
FONT_BACKSPACE      EQU 14
FONT_TAB            EQU 15
FONT_INC_X          EQU 16      ; De la 17 a la 31 libres


;-------------------------------------------------------------
; Tabla con las direcciones de las 16 rutinas de cambio. Notese
; que la numero 9 queda libre para una posible ampliacion.
;-------------------------------------------------------------
FONT_CALL_JUMP_TABLE:
  DW 0000, Font_Set_Style, Font_Set_X, Font_Set_Y, Font_Set_Ink
  DW Font_Set_Paper, Font_Set_Attrib, Font_Set_Bright
  DW Font_Set_Flash, 0000, Font_LF, Font_CRLF, Font_Blank
  DW Font_CR, Font_Backspace, Font_Tab, Font_Inc_X
 

;-------------------------------------------------------------
; Establecer el CHARSET en USO
; Entrada :  HL = direccion del charset en memoria
;-------------------------------------------------------------
Font_Set_Charset:
   LD (FONT_CHARSET), HL
   RET


;-------------------------------------------------------------
; Establecer el estilo de texto en uso.
; Entrada :  A = estilo
;-------------------------------------------------------------
Font_Set_Style:
   LD (FONT_STYLE), A
   RET


;-------------------------------------------------------------
; Establecer la coordenada X en pantalla.
; Entrada :  A = coordenada X
;-------------------------------------------------------------
Font_Set_X:
   LD (FONT_X), A
   RET


;-------------------------------------------------------------
; Establecer la coordenada Y en pantalla.
; Entrada :  A = coordenada Y
;-------------------------------------------------------------
Font_Set_Y:
   LD (FONT_Y), A
   RET


;-------------------------------------------------------------
; Establecer la posicion X,Y del curso de fuente en pantalla.
; Entrada :  B = Coordenada Y
;            C = Coordenada X
;-------------------------------------------------------------
Font_Set_XY:
   LD (FONT_X), BC
   RET


;-------------------------------------------------------------
; Establecer un valor de tinta para el atributo en curso.
; Entrada :  A = Tinta (0-7)
; Modifica:  AF
;-------------------------------------------------------------
Font_Set_Ink:
   PUSH BC                   ; Preservamos registros
   AND 7                     ; Borramos bits 7-3
   LD B, A                   ; Lo guardamos en B
   LD A, (FONT_ATTRIB)       ; Cogemos el atributo actual
   AND %11111000             ; Borramos el valor de INK
   OR B                      ; Insertamos INK en A
   LD (FONT_ATTRIB), A       ; Guardamos el valor de INK
   POP BC
   RET


;-------------------------------------------------------------
; Establecer un valor de papel para el atributo en curso.
; Entrada :  A = Papel (0-7)
; Modifica:  AF
;-------------------------------------------------------------
Font_Set_Paper:
   PUSH BC                   ; Preservamos registros
   AND 7                     ; Borramos bits 7-3
   RLCA                      ; A = 00000XXX -> 0000XXX0
   RLCA                      ; A = 000XXX00
   RLCA                      ; A = 00XXX000 <-- Valor en paper
   LD B, A                   ; Lo guardamos en B
   LD A, (FONT_ATTRIB)       ; Cogemos el atributo actual
   AND %11000111             ; Borramos los datos de PAPER
   OR B                      ; Insertamos PAPER en A
   LD (FONT_ATTRIB), A       ; Guardamos el valor de PAPER
   POP BC
   RET


;-------------------------------------------------------------
; Establecer un valor de atributo para la impresion.
; Entrada :  A = Tinta
;-------------------------------------------------------------
Font_Set_Attrib:
   LD (FONT_ATTRIB), A
   RET


;-------------------------------------------------------------
; Establecer un valor de brillo (1/0) en el atributo actual.
; Entrada :  A = Brillo (0-7)
; Modifica:  AF
;-------------------------------------------------------------
Font_Set_Bright:
   AND 1                     ; A = solo bit 0 de A
   LD A, (FONT_ATTRIB)       ; Cargamos en A el atributo
   JR NZ, fsbright_1         ; Si el bit solicitado era 
   RES 6, A                  ; Seteamos a 0 el bit de flash
   LD (FONT_ATTRIB), A       ; Escribimos el atributo
   RET
fsbright_1:
   SET 6, A                  ; Seteamos a 1 el bit de brillo
   LD (FONT_ATTRIB), A       ; Escribimos el atributo
   RET


;-------------------------------------------------------------
; Establecer un valor de flash (1/0) en el atributo actual.
; Entrada :  A = Flash (1/0)
; Modifica:  AF
;-------------------------------------------------------------
Font_Set_Flash:
   AND 1                     ; A = solo bit 0 de A
   LD A, (FONT_ATTRIB)       ; Cargamos en A el atributo
   JR NZ, fsflash_1          ; Si el bit solicitado era 
   RES 7, A                  ; Seteamos a 0 el bit de flash
   LD (FONT_ATTRIB), A       ; Escribimos el atributo
   RET
fsflash_1:
   SET 7, A                  ; Seteamos a 1 el bit de flash
   LD (FONT_ATTRIB), A       ; Escribimos el atributo
   RET


;-------------------------------------------------------------
; Imprime un espacio, sobreescribiendo la posicion actual del
; cursor e incrementando X en una unidad.
; de la pantalla (actualizando Y en consecuencia).
; Modifica:  AF
;-------------------------------------------------------------
Font_Blank:
   LD A, ' '                 ; Imprimir caracter espacio
   PUSH BC
   PUSH DE
   PUSH HL
   CALL PrintChar_8x8        ; Sobreescribir caracter
   POP HL
   POP DE
   POP BC
   CALL Font_Inc_X           ; Incrementamos la coord X
   RET



;-------------------------------------------------------------
; Incrementa en 1 la coordenada X teniendo en cuenta el borde
; de la pantalla (actualizando Y en consecuencia).
; Modifica:  AF
;-------------------------------------------------------------
Font_Inc_X:
   LD A, (FONT_X)            ; Incrementamos la X
   INC A                     ; pero comprobamos si borde derecho
   CP FONT_SCRWIDTH-1        ; X > ANCHO-1?
   JR C, fincx_noedgex       ; No, se puede guardar el valor
   CALL Font_CRLF
   RET

fincx_noedgex:
   LD (FONT_X), A            ; Establecemos el valor de X
   RET


;-------------------------------------------------------------
; Produce un LineFeed (incrementa Y en 1). Tiene en cuenta
; las variables de altura de la pantalla.
; Modifica:  AF
;-------------------------------------------------------------
Font_LF:
   LD A, (FONT_Y)            ; Cogemos coordenada Y
   CP FONT_SCRHEIGHT-1       ; Estamos en la parte inferior
   JR NC, fontlf_noedge      ; de pantalla? -> No avanzar
   INC A                     ; No estamos, avanzar
   LD (FONT_Y), A

fontlf_noedge:
   RET


;-------------------------------------------------------------
; Produce un Retorno de Carro (Carriage Return) -> X=0.
; Modifica:  AF
;-------------------------------------------------------------
Font_CR:
   XOR A
   LD (FONT_X), A
   RET


;-------------------------------------------------------------
; Provoca un LF y un CR en ese orden.
; Modifica:  AF
;-------------------------------------------------------------
Font_CRLF:
   CALL Font_LF
   CALL Font_CR
   RET


;-------------------------------------------------------------
; Imprime un tabulador (3 espacios) mediante PrintString.
; Modifica:  AF
;-------------------------------------------------------------
Font_Tab:
   PUSH BC
   PUSH DE
   PUSH HL
   LD HL, font_tab_string
   CALL PrintString_8x8_Format      ; Imprimimos 3 espacios
   POP HL
   POP DE
   POP BC
   RET

font_tab_string  DB  "   ", 0


;-------------------------------------------------------------
; Decrementa la coordenada X, simultando un backspace.
; No realiza el borrado en si.
; Modifica:  AF
;-------------------------------------------------------------
Font_Dec_X:
   LD A, (FONT_X)            ; Cargamos la coordenada X
   OR A
   RET Z                     ; Es cero? no se hace nada (salir)
   DEC A                     ; No es cero? Decrementar
   LD (FONT_X), A
   RET                       ; Salir


;-------------------------------------------------------------
; Decrementa la coordenada X, simultando un backspace. No
; realiza el borrado en si.
; Modifica:  AF
;-------------------------------------------------------------
Font_Backspace:
   CALL Font_Dec_X
   LD A, ' '                 ; Imprimir caracter espacio
   PUSH BC
   PUSH DE
   PUSH HL
   CALL PrintChar_8x8        ; Sobreescribir caracter
   POP HL
   POP DE
   POP BC
   RET                       ; Salir



;-------------------------------------------------------------
; PrintString_8x8_Format:
; Imprime una cadena de texto de un charset de fuente 8x8.
;
; Entrada (paso por parametros en memoria):
; -----------------------------------------------------
; FONT_CHARSET = Direccion de memoria del charset.
; FONT_X       = Coordenada X en baja resolucion (0-31)
; FONT_Y       = Coordenada Y en baja resolucion (0-23)
; FONT_ATTRIB  = Atributo a utilizar en la impresion.
; Registro HL  = Puntero a la cadena de texto a imprimir.
;                Debe acabar en cero (FONT_EOS).
; Usa: DE, BC
;-------------------------------------------------------------
PrintString_8x8_Format:
   
   ;;; Bucle de impresion de caracter
pstring8_loop:
   LD A, (HL)                ; Leemos un caracter de la cadena
   INC HL                    ; Apuntamos al siguiente caracter

   CP 32                     ; Es menor que 32?
   JP C,  pstring8_ccontrol  ; Si, es un codigo de control, saltar

   PUSH HL                   ; Salvaguardamos HL
   CALL PrintChar_8x8        ; Imprimimos el caracter
   POP HL                    ; Recuperamos HL

   ;;; Avanzamos el cursor usando Font_Blank, que incrementa X
   ;;; y actualiza X e Y si se llega al borde de la pantalla
   CALL Font_Inc_X           ; Avanzar coordenada X
   JR pstring8_loop          ; Continuar impresion hasta CHAR=0

pstring8_ccontrol:
   OR A                      ; A es cero? 
   RET Z                     ; Si es 0 (fin de cadena) volver
   
   ;;; Si estamos aqui es porque es un codigo de control distinto > 0
   ;;; Ahora debemos calcular la direccion de la rutina que lo atendera.

   ;;; Calculamos la direccion destino a la que saltar usando
   ;;; la tabla de saltos y el codigo de control como indice
   EX DE, HL
   LD HL, FONT_CALL_JUMP_TABLE
   RLCA                      ; A = A * 2 = codigo de control * 2
   LD C, A
   LD B, 0                   ; BC = A*2
   ADD HL, BC                ; HL = DIR FONT_CALL_JUMP_TABLE+(CodControl*2)
   LD C, (HL)                ; Leemos la parte baja de la direccion en C...
   INC HL                    ; ... para no corromper HL y poder leer ...
   LD H, (HL)                ; ... la parte alta sobre H ...
   LD L, C                   ; No hemos usado A porque se usa en el CP

   ;;; Si CCONTROL>0 y CCONTROL<10 -> recoger parametro y saltar a rutina
   ;;; Si CCONTROL>9 y CCONTROL<32 -> saltar a rutina sin recogida
   CP 18                     ; Comprobamos si (CCONTROL-1)*2 < 18
   JP NC, pstring8_noparam   ; Es decir, si CCONTROL > 9, no hay param

   ;;; Si CCONTROL < 10 -> recoger parametro:
   LD A, (DE)                ; Cogemos el parametro en cuestion de la cadena
   INC DE                    ; Apuntamos al siguiente caracter

   ;;; Realizamos el salto a la rutina con o sin parametro recogido
pstring8_noparam:
   LD BC, pstring8_retaddr   ; Ponemos en BC la dir de retorno
   PUSH BC                   ; Hacemos un push de la dir de retorno
   JP (HL)                   ; Saltamos a la rutina seleccionada

   ;;; Este es el punto al que volvemos tras la rutina
pstring8_retaddr:
   EX DE, HL                 ; Recuperamos en HL el puntero a cadena
   JR pstring8_loop          ; Continuamos en el bucle
   RET



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
   SUB 8              ; Restando los 7 scanlines avanzados

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

END 32768

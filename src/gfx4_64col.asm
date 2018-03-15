  ; Ejemplo de fuente de 4x8 pixeles (64 caracteres por linea)
  ORG 32768

  LD HL, charset_4x8-128                    ; Inicio charset - (256/2)
  CALL Font_Set_Charset

  LD HL, cadena1
  LD BC, $0400                              ; X=00, Y=04
  CALL Font_Set_XY
  CALL PrintString_4x8_Format

loop: 
  JR loop
  RET

cadena1 DB "Fuente de 4x8", FONT_CRLF, FONT_CRLF
        DB "Esto es un texto impreso a 64 columnas con fuente "
        DB "de 4x8 pixeles. La letra tiene la mitad de anchura "
        DB "que la estandar pero todavia se lee con facilidad."
        DB FONT_CRLF, FONT_CRLF
        DB "Con esta fuente se pueden realizar juegos basados en "
        DB "texto pero hay que tener en cuenta que los atributos "
        DB FONT_SET_INK, 2, "afectan a 2 caracteres ", FONT_SET_INK, 0
        DB "a la vez, por lo que es mejor no cambiar el paper y "
        DB "modificarlos solo antes o tras un espacio."
        DB FONT_EOS


;-------------------------------------------------------------



; half width 4x8 font - 384 bytes
charset_4x8:
   DB $00,$02,$02,$02,$02,$00,$02,$00,$00,$52,$57,$02,$02,$07,$02,$00
   DB $00,$25,$71,$62,$32,$74,$25,$00,$00,$22,$42,$30,$50,$50,$30,$00
   DB $00,$14,$22,$41,$41,$41,$22,$14,$00,$20,$70,$22,$57,$02,$00,$00
   DB $00,$00,$00,$00,$07,$00,$20,$20,$00,$01,$01,$02,$02,$04,$14,$00
   DB $00,$22,$56,$52,$52,$52,$27,$00,$00,$27,$51,$12,$21,$45,$72,$00
   DB $00,$57,$54,$56,$71,$15,$12,$00,$00,$17,$21,$61,$52,$52,$22,$00
   DB $00,$22,$55,$25,$53,$52,$24,$00,$00,$00,$00,$22,$00,$00,$22,$02
   DB $00,$00,$10,$27,$40,$27,$10,$00,$00,$02,$45,$21,$12,$20,$42,$00
   DB $00,$23,$55,$75,$77,$45,$35,$00,$00,$63,$54,$64,$54,$54,$63,$00
   DB $00,$67,$54,$56,$54,$54,$67,$00,$00,$73,$44,$64,$45,$45,$43,$00
   DB $00,$57,$52,$72,$52,$52,$57,$00,$00,$35,$15,$16,$55,$55,$25,$00
   DB $00,$45,$47,$45,$45,$45,$75,$00,$00,$62,$55,$55,$55,$55,$52,$00
   DB $00,$62,$55,$55,$65,$45,$43,$00,$00,$63,$54,$52,$61,$55,$52,$00
   DB $00,$75,$25,$25,$25,$25,$22,$00,$00,$55,$55,$55,$55,$27,$25,$00
   DB $00,$55,$55,$25,$22,$52,$52,$00,$00,$73,$12,$22,$22,$42,$72,$03
   DB $00,$46,$42,$22,$22,$12,$12,$06,$00,$20,$50,$00,$00,$00,$00,$0F
   DB $00,$20,$10,$03,$05,$05,$03,$00,$00,$40,$40,$63,$54,$54,$63,$00
   DB $00,$10,$10,$32,$55,$56,$33,$00,$00,$10,$20,$73,$25,$25,$43,$06
   DB $00,$42,$40,$66,$52,$52,$57,$00,$00,$14,$04,$35,$16,$15,$55,$20
   DB $00,$60,$20,$25,$27,$25,$75,$00,$00,$00,$00,$62,$55,$55,$52,$00
   DB $00,$00,$00,$63,$55,$55,$63,$41,$00,$00,$00,$53,$66,$43,$46,$00
   DB $00,$00,$20,$75,$25,$25,$12,$00,$00,$00,$00,$55,$55,$27,$25,$00
   DB $00,$00,$00,$55,$25,$25,$53,$06,$00,$01,$02,$72,$34,$62,$72,$01
   DB $00,$24,$22,$22,$21,$22,$22,$04,$00,$56,$A9,$06,$04,$06,$09,$06

;-------------------------------------------------------------
FONT_CHARSET     DW    $3D00-256
FONT_ATTRIB      DB    56
FONT_STYLE       DB    0
FONT_X           DB    0
FONT_Y           DB    0
FONT_SCRWIDTH    EQU   64
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
  DW Font_Set_Style, Font_Set_X, Font_Set_Y, Font_Set_Ink
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
   CALL PrintChar_4x8        ; Sobreescribir caracter
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
   CALL PrintString_4x8_Format      ; Imprimimos 3 espacios
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
   CALL PrintChar_4x8        ; Sobreescribir caracter
   POP HL
   POP DE
   POP BC
   RET                       ; Salir



;-------------------------------------------------------------
; PrintString_4x8_Format:
; Imprime una cadena de texto de un charset de fuente 4x8.
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
PrintString_4x8_Format:
   
   ;;; Bucle de impresion de caracter
pstring4_loop:
   LD A, (HL)                ; Leemos un caracter de la cadena
   INC HL                    ; Apuntamos al siguiente caracter

   CP 32                     ; Es menor que 32?
   JP C,  pstring4_ccontrol  ; Si, es un codigo de control, saltar

   PUSH HL                   ; Salvaguardamos HL
   CALL PrintChar_4x8        ; Imprimimos el caracter
   POP HL                    ; Recuperamos HL

   ;;; Avanzamos el cursor usando Font_Blank, que incrementa X
   ;;; y actualiza X e Y si se llega al borde de la pantalla
   CALL Font_Inc_X           ; Avanzar coordenada X
   JR pstring4_loop          ; Continuar impresion hasta CHAR=0

pstring4_ccontrol:
   OR A                      ; A es cero? 
   RET Z                     ; Si es 0 (fin de cadena) volver
   
   ;;; Si estamos aqui es porque es un codigo de control distinto > 0
   ;;; Ahora debemos calcular la direccion de la rutina que lo atendera.

   ;;; Calculamos la direccion destino a la que saltar usando
   ;;; la tabla de saltos y el codigo de control como indice
   EX DE, HL
   LD HL, FONT_CALL_JUMP_TABLE
   DEC A                     ; Decrementamos A (puntero en tabla)
   RLCA                      ; A = A * 2 = codigo de control * 2
   LD C, A
   LD B, 0                   ; BC = A*2
   ADD HL, BC                ; HL = DIR FONT_CALL_JUMP_TABLE+(CodControl*2)
   LD C, (HL)                
   INC HL
   LD H, (HL)
   LD L, C                   ; Leemos la direccion de la tabla en HL

   ;;; Si CCONTROL>0 y CCONTROL<10 -> recoger parametro y saltar a rutina
   ;;; Si CCONTROL>9 y CCONTROL<32 -> saltar a rutina sin recogida
   CP 18                     ; Comprobamos si (CCONTROL-1)*2 < 18
   JP NC, pstring4_noparam   ; Es decir, si CCONTROL > 9, no hay param

   ;;; Si CCONTROL < 10 -> recoger parametro:
   LD A, (DE)                ; Cogemos el parametro en cuestion de la cadena
   INC DE                    ; Apuntamos al siguiente caracter

   ;;; Realizamos el salto a la rutina con o sin parametro recogido
pstring4_noparam:
   LD BC, pstring4_retaddr   ; Ponemos en BC la dir de retorno
   PUSH BC                   ; Hacemos un push de la dir de retorno
   JP (HL)                   ; Saltamos a la rutina seleccionada

   ;;; Este es el punto al que volvemos tras la rutina
pstring4_retaddr:
   EX DE, HL                 ; Recuperamos en HL el puntero a cadena
   JR pstring4_loop          ; Continuamos en el bucle



;-------------------------------------------------------------
; PrintChar_4x8:
; Imprime un caracter de 4x8 pixeles de un charset.
;
; Entrada (paso por parametros en memoria):
; -----------------------------------------------------
; FONT_CHARSET = Direccion de memoria del charset.
; FONT_X       = Coordenada X en baja resolucion (0-31)
; FONT_Y       = Coordenada Y en baja resolucion (0-23)
; FONT_ATTRIB  = Atributo a utilizar en la impresion.
; Registro A   = ASCII del caracter a dibujar.
;-------------------------------------------------------------
PrintChar_4x8:

   RRA                       ; Dividimos A por 2 (resto en CF)
   PUSH AF                   ; Guardamos caracter y CF en A'

   ;;; Calcular posicion origen (array fuente) en HL como:
   ;;;     direccion = base_charset + ((CARACTER/2)*8)
   LD BC, (FONT_CHARSET)
   LD H, 0
   LD L, A
   ADD HL, HL
   ADD HL, HL
   ADD HL, HL
   ADD HL, BC                ; HL = Direccion origen de A en fuente

   ;;; Calculamos las coordenadas destino de pantalla en DE:
   LD BC, (FONT_X)           ; B = Y,  C = X
   RR C
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
   LD E, A                  ; DE contiene ahora la direccion destino.

   ;;; Calculamos posición en pantalla. Tenemos que dividirla por 2 porque
   ;;; en cada columna de pantalla caben 2 caracteres. Usaremos el resto 
   ;;; (Carry) para saber si va en la izq (CF=0) o der (CF=1) del caracter.
   LD A, (FONT_X)            ; Volvemos a leer coordenada X
   RRA                       ; Dividimos por 2 (posicion X en pantalla)
                             ; Ademas el carry tiene el resto (par/impar)
   JR NC, pchar4_x_odd       ; Saltar si es columna impar (por el CF)

   ;;; Ahora tenemos que imprimir el caracter en pantalla. Hemos saltado
   ;;; a pchar4_x_even o pchar4_x_odd segun si la posicion en pantalla es
   ;;; par o impar, pero cada una de estas 2 opciones nos da la posibilidad
   ;;; de usar una rutina u otra segun si el caracter ASCII es par o impar
   ;;; ya que tenemos que cogerlo de la fuente de una forma u otra
   ;;; Posicion de columna en pantalla par:
pchar4_x_even  :
   POP AF                    ; Restaura A=char y CF=si es char par/impar
   JR C, pchar4_l_on_l
   JR pchar4_r_on_l

pchar4_x_odd:
   POP AF                    ; Restaura A=char y CF=si es char par/impar
   JR NC, pchar4_r_on_r
   JR pchar4_l_on_r

pchar4_continue:

   ;;; Impresion de los atributos
pchar4_printattr:

   LD A, D            ; Recuperamos el valor inicial de DE
   SUB 8              ; Restando los 8 scanlines avanzados

   ;;; Calcular posicion destino en area de atributos en HL.
   RRCA               ; A ya es = D, listo para rotar
   RRCA               ; Codigo de Get_Attr_Offset_From_Image
   RRCA
   AND 3
   OR $58
   LD H, A
   LD L, E

   ;;; Escribir el atributo en memoria
   LD A, (FONT_ATTRIB)
   LD (HL), A         ; Escribimos el atributo en memoria
   RET


;;;------------------------------------------------------------------
;;; "Subrutinas" de impresion de caracter de 4x8
;;; Entrada: HL = posicion del caracter en la fuente 4x8
;;;          DE = posicion en pantalla del primer scanline
;;;------------------------------------------------------------------

;;;----------------------------------------------------
pchar4_l_on_l:
   LD B, 8                   ; 8 scanlines / iteraciones
pchar4_ll_lp: 
   LD A, (DE)                ; Leer byte de la pantalla
   AND %11110000
   LD C, A                   ; Nos lo guardamos en C
   LD A, (HL)                ; Cogemos el byte de la fuente
   AND %00001111
   OR C                      ; Lo combinamos con el fondo
   LD (DE), A                ; Y lo escribimos en pantalla
   INC D                     ; Siguiente scanline
   INC HL                    ; Siguiente dato del "sprite"
   DJNZ pchar4_ll_lp
   JR pchar4_continue        ; Volver tras impresion


;;;----------------------------------------------------
pchar4_r_on_r: 
   LD B, 8                   ; 8 scanlines / iteraciones
pchar4_rr_lp:
   LD A, (DE)                ; Leer byte de la pantalla
   AND %00001111
   LD C, A                   ; Nos lo guardamos en C
   LD A, (HL)                ; Cogemos el byte de la fuente
   AND %11110000
   OR C                      ; Lo combinamos con el fondo
   LD (DE), A                ; Y lo escribimos en pantalla
   INC D                     ; Siguiente scanline
   INC HL                    ; Siguiente dato del "sprite"
   DJNZ pchar4_rr_lp
   JR pchar4_continue        ; Volver tras impresion


;;;----------------------------------------------------
pchar4_l_on_r: 
   LD B, 8                   ; 8 scanlines / iteraciones
pchar4_lr_lp: 
   LD A, (DE)                ; Leer byte de la pantalla
   AND %00001111
   LD C, A                   ; Nos lo guardamos en C
   LD A, (HL)                ; Cogemos el byte de la fuente
   RRCA                      ; Lo desplazamos 4 veces >> dejando
   RRCA                      ; lo bits 4 al 7 vacios
   RRCA
   RRCA
   AND %11110000
   OR C                      ; Lo combinamos con el fondo
   LD (DE), A                ; Y lo escribimos en pantalla
   INC D                     ; Siguiente scanline
   INC HL                    ; Siguiente dato del "sprite"
   DJNZ pchar4_lr_lp
   JR pchar4_continue        ; Volver tras impresion


;;;----------------------------------------------------
pchar4_r_on_l: 
   LD B, 8                   ; 8 scanlines / iteraciones
pchar4_rl_lp: 
   LD A, (DE)                ; Leer byte de la pantalla
   AND %11110000
   LD C, A                   ; Nos lo guardamos en C
   LD A, (HL)                ; Cogemos el byte de la fuente
   RLCA                      ; Lo desplazamos 4 veces << dejando
   RLCA                      ; los bits 0 al 3 vacios
   RLCA
   RLCA
   AND %00001111
   OR C                      ; Lo combinamos con el fondo
   LD (DE), A                ; Y lo escribimos en pantalla
   INC D                     ; Siguiente scanline
   INC HL                    ; Siguiente dato del "sprite"
   DJNZ pchar4_rl_lp
   JR pchar4_continue        ; Volver tras impresion

END 32768

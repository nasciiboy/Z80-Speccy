  ; Mostrando la organizacion de la videomemoria (atributos)

  ORG 50000

  ; Pseudocodigo del programa:
  ; 
  ; Borramos la pantalla
  ; Apuntamos HL a 22528
  ; Repetimos 24 veces:
  ;    Esperamos pulsacion de una tecla
  ;    Repetimos 32 veces:
  ;       Escribir un valor de PAPEL 0-7 en la direccion apuntada por HL
  ;       Incrementar HL

Start:

  LD A, 1                    ; Borde azul
  CALL SetBorder
  LD A, 0
  CALL ClearScreen           ; Borramos la pantalla
  LD A, 8+4                  ; Atributos: rojo sobre azul
  CALL ClearAttributes

  LD HL, linea1
  CALL PrintString

  LD A, 12
  LD (23695), A              ; Atributos

  LD HL, linea2
  CALL PrintString

  LD A, 64+2+9              ; Atributos: m + brillo.
  LD (23695), A

  LD HL, linea2
  CALL PrintString

  ; Esperamos que se pulse y libere tecla
  CALL Wait_For_Keys_Pressed
  CALL Wait_For_Keys_Released

  RET                       ; Fin del programa


;-----------------------------------------------------------------------
; Esta rutina espera a que haya alguna tecla pulsada para volver.
;-----------------------------------------------------------------------
Wait_For_Keys_Pressed:
  XOR A   
  IN A, (254)
  OR 224
  INC A
  JR Z, Wait_For_Keys_Pressed
  RET

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

;-------------------------------------------------------------------------
; SetBorder: Cambio del color del borde al del registro A
; Se establece BORDCR tal cual lo requiere BASIC.
;-------------------------------------------------------------------------
SetBorder:
  OUT (254), A           ; Cambiamos el color del borde
  RLCA
  RLCA
  RLCA                   ; A = A*8 (colocar en bits PAPER)
  BIT 5, A               ; Mirar si es un color BRIGHT
  JR NZ, SetBorder_fin   ; No es bright -> guardarlo
                         ; Si es bright
  XOR 7                  ; -> cambiar la tinta a 0
  
SetBorder_fin:
  LD (23624), A          ; Salvar el valor en BORDCR
  RET

;-------------------------------------------------------------------------
; PrintString: imprime una cadena acabada en valor cero (no caracter 0).
; HL = direccion de la cadena de texto a imprimir.
;-------------------------------------------------------------------------
PrintString:
 
printstrloop:
  LD A, (HL)             ; Obtener el siguiente caracter a imprimir
  CP 0                   ; Comprobar si es un 0 (fin de linea)
  RET Z                  ; Si es cero, fin de la rutina
  RST 16                 ; No es cero, imprimir caracter o codigo
                         ; de control (13=enter, etc).
  INC HL                 ; Avanzar al siguiente caracter
  JP printstrloop        ; Repetir bucle         
  ret
 

;-------------------------------------------------------------------------
; Datos
;-------------------------------------------------------------------------
linea1:  defb 'Impreso con ATTR-T actual', 13, 13, 0
linea2:  defb 'Esto es una prueba',13,'cambiando los atributos', 13, 13, 0


END 50000


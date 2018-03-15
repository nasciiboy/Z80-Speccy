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
  LD A, 0
  CALL ClearScreen           ; Borramos la pantalla

  LD HL, 22528               ; HL apunta a la VRAM
  LD B, 24                  ; Repetimos para 192 lineas

bucle_lineas:
  LD D, B                    ; Nos guardamos el valor de D para el
                             ; bucle exterior (usaremos B ahora en otro)
  LD B, 32                   ; B=32 para el bucle interior

                             ; Esperamos que se pulse y libere tecla
  CALL Wait_For_Keys_Pressed
  CALL Wait_For_Keys_Released

  LD A, (papel)              ; Cogemos el valor del papel
  INC A                      ; Lo incrementamos
  LD (papel), A              ; Lo guardamos de nuevo
  CP 8                       ; Si es == 8 (>7), resetear
  JR NZ,no_resetear_papel

  LD A, 255
  LD (papel), A              ; Lo hemos reseteado: lo guardamos
  XOR A                      ; A=0

no_resetear_papel:

  SLA A                      ; Desplazamos A 3 veces a la izquierda
  SLA A                      ; para colocar el valor 0-7 en los bits
  SLA A                      ; donde se debe ubicar PAPER (bits 3-5).

bucle_32_bytes:
  LD (HL), A                 ; Almacenamos A en (HL) = attrib de 8x8
  INC HL                     ; siguiente byte (siguientes 8x8 pixeles.)
  DJNZ bucle_32_bytes        ; 32 veces = 32 bytes = 1 scanline de bloques

  LD B, D                    ; Recuperamos el B del bucle exterior
 
  DJNZ bucle_lineas          ; Repetir 24 veces

  JP Start                   ; Inicio del programa

papel  defb   255            ; Valor del papel


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
  LD HL, 16384
  LD (HL), A
  LD DE, 16385
  LD BC, 192*32-1
  LDIR
  RET


END 50000

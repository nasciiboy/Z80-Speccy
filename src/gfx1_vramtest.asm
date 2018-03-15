  ; Mostrando la organizacion de la videomemoria

  ORG 50000

  ; Pseudocodigo del programa:
  ; 
  ; Limpiamos la pantalla
  ; Apuntamos HL a 16384
  ; Repetimos 192 veces:
  ;    Esperamos pulsacion de una tecla
  ;    Repetimos 32 veces:
  ;       Escribir 255 en la direccion apuntada por HL
  ;       Incrementar HL

Start:
  LD A, 0
  CALL ClearScreen           ; Borramos la pantalla

  LD HL, 16384               ; HL apunta a la VRAM
  LD B, 192                  ; Repetimos para 192 lineas

bucle_192_lineas:
  LD D, B                    ; Nos guardamos el valor de D para el
                             ; bucle exterior (usaremos B ahora en otro)
  LD B, 32                   ; B=32 para el bucle interior

                             ; Esperamos que se pulse y libere tecla
  CALL Wait_For_Keys_Pressed
  CALL Wait_For_Keys_Released

  LD A, 255                  ; 255 = 11111111b = todos los pixeles

bucle_32_bytes:
  LD (HL), A                 ; Almacenamos A en (HL) = 8 pixeles
  INC HL                     ; siguiente byte (siguientes 8 pix.)
  DJNZ bucle_32_bytes        ; 32 veces = 32 bytes = 1 scanline

  LD B, D                    ; Recuperamos el B del bucle exterior
 
  DJNZ bucle_192_lineas      ; Repetir 192 veces

  JP Start                   ; Inicio del programa

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

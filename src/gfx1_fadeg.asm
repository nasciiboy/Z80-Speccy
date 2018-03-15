  ; Fundido de los pixeles a cero con una cortinilla

  ORG 50000

Start:

  ; Rellenamos la VRAM de pixeles copiando 6 KB de la ROM

  LD HL, 0
  LD DE, 16384
  LD BC, 6144
  LDIR

  CALL Wait_For_Keys_Pressed
  CALL Wait_For_Keys_Released
  CALL FadeScreen

  RET

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
; Fundido de pantalla decrementando los pixeles de pantalla
;-----------------------------------------------------------------------
FadeScreen:
   PUSH AF
   PUSH BC
   PUSH DE
   PUSH HL                      ; Preservamos los registros
   
   LD B, 9                      ; Repetiremos el bucle 9 veces
   LD C, 0                      ; Nuestro contador de columna

fadegfx_loop1:
   LD HL, 16384                 ; Apuntamos HL a la zona de atributos
   LD DE, 6144                  ; Iteraciones bucle

fadegfx_loop2:
   LD A, (HL)                   ; Cogemos el grupo de 8 pixeles


   ;-- Actuamos sobre el valor de los pixeles --
   CP 0                         ;
   JR Z, fadegfx_save           ; Si ya es cero, no hacemos nada

   EX AF, AF'                   ; Nos guardamos el dato

   LD A, C                      ; Pasamos el contador a A
   CP 15                        ; Comparamos A con 15
   JR NC, fadegfx_mayor15       ; Si es mayor, saltamos
   
   EX AF, AF'                   ; Recuperamos en A los pixeles
   RLA                          ; Rotamos A a la izquierda
   JR fadegfx_save              ; Y guardamos el dato

fadegfx_mayor15:
   EX AF, AF'                   ; Recuperamos en A los pixeles
   SRL A                        ; Rotamos A a la derecha 

   ;-- Fin actuacion sobre el valor de los pixeles --

fadegfx_save:

   LD (HL), A                   ; Almacenamos el atributo modificado
   INC HL                       ; Avanzamos puntero de memoria

   ; Incrementamos el contador y comprobamos si hay que resetearlo
   INC C
   LD A, C
   CP 32
   JR NZ, fadegfx_continue

   LD C, 0

fadegfx_continue:

   DEC DE
   LD A, D
   OR E
   JP NZ, fadegfx_loop2      ; Hasta que DE == 0

   DJNZ fadegfx_loop1        ; Repeticion 9 veces

   POP HL
   POP DE
   POP BC
   POP AF                       ; Restauramos registros
   RET

END 50000

; Ejemplo de WaitNticks
 
  ORG 50000
 
  ; Instalamos la ISR:
  LD HL, CLOCK_ISR_ASM_ROUTINE
  DI
  LD (65279), HL                ; Guardamos en (65279) la direccion de la
  LD A, 254                     ; rutina CLOCK_ISR_ASM_ROUTINE
  LD I, A
  IM 2
  EI
 
Bucle_entrada:

  LD A, "."
  RST 16
  LD A, "5"
  RST 16
  LD A, " "
  RST 16                        ; Imprimimos por pantalla ".5 "
  LD HL, 25                     ; Esperamos 25 ticks (0.5 segundos)
  CALL WaitNTicks

  LD A, "3"
  RST 16
  LD A, " "
  RST 16                        ; Imprimimos por pantalla "3 "
  LD HL, 3*50                   ; Esperamos 150 ticks (3 segundos)
  CALL WaitNTicks

  JP Bucle_entrada
 
ticks         DB 0
timer         DW 0
 
 
;-----------------------------------------------------------------------
; WaitNTicks: Esperamos N ticks de procesador (1/50th) en un bucle.
;-----------------------------------------------------------------------
WaitNTicks:
   LD (timer), HL          ; seteamos "timer" con el tiempo de espera
   
Waitnticks_loop:           ; bucle de espera, la ISR lo ira decrementando
   LD HL, (timer)
   LD A, H                 ; cuando (timer) valga 0 y lo decrementen, su
   CP $FF                  ; byte alto pasara a valer FFh, lo que quiere
                           ; decir que ha pasado el tiempo a esperar.
   JR NZ, Waitnticks_loop  ; si no, al bucle de nuevo.
   RET
  

;-----------------------------------------------------------------------
; Rutina de ISR : incrementa ticks y abs_ticks 50 veces por segundo.
;-----------------------------------------------------------------------
CLOCK_ISR_ASM_ROUTINE:
   PUSH AF
   PUSH HL
 
   LD HL, (timer)
   DEC HL
   LD (timer), HL                ; Decrementamos timer (absolutos)

   LD A, (ticks)
   INC A
   LD (ticks), A                 ; Incrementamos ticks (50 veces/seg)
 
   CP 50
   JR NZ, clock_isr_fin          ; if ticks < 50,  fin de la ISR
                                 ; si ticks >= 50, cambiar seg:min
   XOR A
   LD (ticks), A                 ; ticks = 0
 
clock_isr_fin:
   POP HL
   POP AF
 
   EI
   RETI
 
 
END 50000

;----------------------------------------------------------------------
; Loadscr.asm : Demostración de las rutinas LOAD de la ROM, con
; la carga de un fichero SCR (desde cinta) en videomemoria.
;----------------------------------------------------------------------

  ORG 32000

  AND A                           ; CF = 0 (verify)
  CALL 1366                       ; Cargamos e ignoramos la cabecera

  SCF                             ; Set Carry Flag -> CF=1 -> LOAD
  LD A, 255                       ; A = 0xFF (cargar datos)
  LD IX, 16384                    ; Destino del load = 16384
  LD DE, 6912                     ; Tamaño a cargar = 6912
  CALL 1366                       ; Llamamos a la rutina de carga

  RET 

END 32000

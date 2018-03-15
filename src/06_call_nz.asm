  ; CALL NZ
  ORG 50000

bucle_principal:
   LD A, (estado_pausa)
   OR A
   CALL Z, fin_pausa
   jp bucle_principal

fin_pausa:
   ret

estado_pausa DB 0


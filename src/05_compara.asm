 ; Principio del programa
 ORG 50000

  ; Comparacion entre A Y B (=, > y <)
  LD B, 7
  LD A, 5

  CP B                    ; Flags = estado(A-B)
  JP Z, A_Igual_que_B     ; IF(a-b)=0 THEN a=b
  JP NC, A_Mayor_que_B    ; IF(a-b)>0 THEN a>b
  JP C, A_Menor_que_B     ; IF(a-b)<0 THEN a<b
  
A_Mayor_que_B:
  LD A, 255
  LD (16960), A           ; 8 pixels en la parte sup-izq
  JP fin

A_Menor_que_B:
  LD A, 255
  LD (19056), A           ; centro de la pantalla
  JP fin

A_Igual_que_B:
  LD A, 255
  LD (21470), A           ; parte inferior derecha
  
fin:
  JP fin                  ; bucle infinito, para que podamos ver 
                          ; el resultado de la ejecucion

  END 50000



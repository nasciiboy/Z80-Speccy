  ; Ejemplo de uso de pixel-address (ROM)
  ORG 50000

PIXEL_ADDRESS EQU $22B1

entrada:

  ; Imprimimos un solo pixel en (0,0)
  LD C, 0                ; X = 0
  LD B, 0                ; Y = 0
  LD A, B                ; A = Y = 0
  CALL PIXEL_ADDRESS     ; HL = direccion (0,0)
  LD A, 128              ; A = 10000000b (1 pixel).
  LD (HL), A             ; Imprimimos el pixel

  ; Imprimimos 8 pixeles en (255,191)
  LD C, 255              ; X = 255
  LD B, 191              ; Y = 191
  LD A, B                ; A = Y = 191
  CALL PIXEL_ADDRESS     
  LD A, 255              ; A = 11111111b (8 pixeles)
  LD (HL), A

  ; Imprimimos 4 pixeles en el centro de la pantalla
  LD C, 127              ; X = 127
  LD B, 95               ; Y = 95
  LD A, B                ; A = Y = 95
  CALL PIXEL_ADDRESS     
  LD A, 170              ; A = 10101010b (4 pixeles)
  LD (HL), A

loop:                    ; Bucle para no volver a BASIC y que
  jr loop                ; no se borren la 2 ultimas lineas
 
END 50000

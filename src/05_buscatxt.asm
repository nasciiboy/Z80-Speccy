 ; Principio del programa
 ORG 50000

   LD HL, texto     ; Inicio de la busqueda
   LD A, 'X'        ; Carácter (byte) a buscar
   LD BC, 100       ; Número de bytes donde buscar
   CPIR             ; Realizamos la búsqueda
   
   JP NZ, No_Hay    ; Si no encontramos el caracter buscado
                    ; el flag de Z estará a cero.

                    ; Si estamos aquí es que se encontró
                    
   DEC HL           ; Decrementamos HL para apuntar al byte
                    ; encontrado en memoria.

   SCF
   CCF              ; Ponemos el carry flag a 0 (SCF+CCF)
   LD BC, texto
   SBC HL, BC       ; HL = HL - BC 
                    ;    = (posicion encontrada) - (inicio cadena)
                    ;    = posición de 'X' dentro de la cadena.

   LD B, H
   LD C, L          ; BC = HL
                    
   RET              ; Volvemos a basic con el resultado en BC

No_Hay:
   LD BC, $FFFF
   RET

texto DB "Esto es una X cadena de texto."

  ; Fin del programa
  END



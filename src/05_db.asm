 ; Principio del programa
 ORG 50000

   ; Primero vamos a copiar los datos a la videomemoria.
   LD HL, datos
   LD DE, 16384
   LD BC, 10
   LDIR

   ; Ahora vamos a sumar 1 a cada caracter:
   LD B, 27
bucle:
   LD HL, texto
   LD A, (HL)
   INC A
   LD (HL), A

   DJNZ bucle
   RET

datos DB 0, $FF, $FF, 0, $FF, 12, 0, 0, 0, 10, 255
texto DB "Esto es una cadena de texto"

   ; Fin del programa
   END


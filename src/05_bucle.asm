      ; Ejemplo de un programa con un bucle infinito
      ORG 50000

bucle:
      INC A
      LD (16384), A
      JP bucle

      RET     ; Esto nunca se ejecutará


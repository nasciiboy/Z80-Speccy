
 Suma y resta de números BCD, traducido de:
 http://icarus.ticalc.org/articles/z80_faq.html

 * SUMA BCD:
 ------------

   Entrada: 
     HL = Dirección base (en memoria) del 1er operando a sumar.
     DE = Dirección base del segundo operando a sumar.
      B = Longitud de los números
      (Ambos registros deben de apuntar direcciones de memoria
      que contengan una ristra de "B" dígitos BCD).

   Salida:
      Los datos apuntados por HL cambiarán y valdrán la suma.


  ld      A, B
  or      A
  ret     z         ;test whether length = 0
Loop:
  ld      A, (DE)   ;get byte of adder
  adc     A, (HL)   ;add it to addend, care for carry
  daa                ;convert to BCD-decimal
  ld      (HL), A   ;save number back in addend
  inc     HL        ;next number
  inc     DE
  djnz    Loop      ;continue until all bytes summed
  ret



 * RESTA BCD:
 ------------


   Entrada: 
     HL = Dirección base (en memoria) del 1er operando a restar.
     DE = Dirección base del sustraendo..
      B = Longitud de los números
      (Ambos registros deben de apuntar direcciones de memoria
      que contengan una ristra de "B" dígitos BCD).

   Salida:
      Los datos apuntados por DE cambiarán y valdrán la resta.


  ld      A, B
  or      A
  ret     z         ;test whether length = 0
  ex      DE, HL    ;exchange subtrahend and minuend
Loop:
  ld      A, (DE)   ;get byte of minuend
  sbc     A, (HL)   ;subtract byte of subtrahend
  daa               ;convert to BCD-decimal
  ld      (DE), A   ;save number back in minuend
  inc     HL        ;next number
  inc     DE
  djnz    Loop      ;continue until all bytes summed
  ret


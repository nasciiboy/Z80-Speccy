#!/usr/bin/python
#
# Convierte una pantalla de mapa en pantalla codificada por
# codif. basica, scanlines horizontales, verticales o mixtos.
# Permite agrupacion de coordenadas XY en un mismo byte con
# el flag -a.
#

import os, sys

# Variables de configuracion del script
ANCHO_MAPA = 16
ALTO_MAPA = 12
IGNORE_VALUES = 0
BLANK = 0
agrupar_xy = 0

MIXTA_CODIF_HORIZ  = 0
MIXTA_CODIF_VERT   = 1

#-----------------------------------------------------------------------
def Uso():
   print "\nUso:", sys.argv[0], "TIPO_CODIFICACION [-a] nombre_fichero"
   print "\n  Flag TIPO_CODIFICACION:\n"
   print "    Basica = -b"
   print "    Scanlines horizontales = -h"
   print "    Scanlines verticales= -v"
   print "    Scanlines horizontales = -h"
   print "    Mixta horizontales/verticales = -m\n"
   print "    Flag opcional -a: (por defecto = off)"
   print "    Agrupar coordenadas X e Y en un mismo byte = -a\n"

   sys.exit(1)

#-----------------------------------------------------------------------
def Consecutivos_Horiz( x, y, pantalla, ancho ):
   cuales = []
   tiles = []
   while (x < ancho) and ( pantalla[y][x] != IGNORE_VALUES ):
      cuales.append( x )
      cuales.append( y )
      tiles.append(pantalla[int(y)][int(x)])
      x += 1
   return cuales, tiles

#-----------------------------------------------------------------------
def Consecutivos_Vert( x, y, pantalla, alto ):
   cuales = []
   tiles = []
   while (y < alto) and ( pantalla[y][x] != IGNORE_VALUES ):
      cuales.append( x )
      cuales.append( y )
      tiles.append(pantalla[y][x])
      y += 1
   return cuales, tiles

#-----------------------------------------------------------------------
def Borrar_Consecutivos( pantalla, lista ):
   for i in range(0,len(lista),2):
      x = lista[i]
      y = lista[i+1]
      pantalla[y][x] = BLANK
   return pantalla

#-----------------------------------------------------------------------
def Codificacion_Horiz_o_Vert( pantalla ):

   COORD_Y = 0
   mapa_codificado = []

   # Procesamos la matriz de datos (la pantalla) segun la codificacion:
   for y in range(0,ALTO_MAPA):
      COORD_X = 0

      # Procesar los valores separados por coma:
      for valor in pantalla[y]:
         if codificacion == "-b":
            if valor != IGNORE_VALUES:
               if agrupar_xy == 0:
                  mapa_codificado.append( COORD_X )
                  mapa_codificado.append( COORD_Y )
               else:
                  mapa_codificado.append( (COORD_X*16) + COORD_Y )
               mapa_codificado.append( valor )
         elif codificacion == "-h" or codificacion == "-v":
            if valor != IGNORE_VALUES:
               if agrupar_xy == 0:
                  mapa_codificado.append( COORD_X )
                  mapa_codificado.append( COORD_Y )
               else:
                  mapa_codificado.append( (COORD_X*16) + COORD_Y )
               if codificacion == "-h":
                  a, b = Consecutivos_Horiz(COORD_X, COORD_Y, pantalla, ANCHO_MAPA)
               else:
                  a, b = Consecutivos_Vert(COORD_X, COORD_Y, pantalla, ALTO_MAPA)
               pantalla = Borrar_Consecutivos( pantalla, a )
               mapa_codificado.extend( b )
               mapa_codificado.append( 255 );
         COORD_X += 1
      COORD_Y += 1

   return mapa_codificado

#-----------------------------------------------------------------------
def Tiles_Pendientes( pantalla ):
   cuantos = 0
   for y in range(0,len(pantalla)):
      for value in pantalla[y]:
         if value != IGNORE_VALUES:
            cuantos += 1
   return cuantos

#-----------------------------------------------------------------------
def Coordenadas_Mayor_Valor( matriz ):
   maxx, maxy, maxv = 0, 0, 0

   for y in range(0,len(matriz)):
      for x in range(len(matriz[y])):
         valor = matriz[y][x]
         if valor != IGNORE_VALUES and valor > maxv:
            maxv = valor
            maxx = x
            maxy = y

   return maxx, maxy, maxv

#-----------------------------------------------------------------------
def Codificacion_Mixta( pantalla ):

   mapa_codificado_h = []
   mapa_codificado_v = []
   mapa_codificado = []

   # Repetir hasta que no queden tiles que codificar:
   while Tiles_Pendientes(pantalla) != 0:

      # Construir 2 tablas con la cantidad de tiles horizontales y
      # verticales que salen de codificar cada posicion:
      horizontales = [ [ 0 for i in range(0,ANCHO_MAPA) ] for j in range(0,ALTO_MAPA) ]
      verticales = [ [ 0 for i in range(0,ANCHO_MAPA) ] for j in range(0,ALTO_MAPA) ]

      COORD_Y = 0
      for y in range(0,ALTO_MAPA):
         COORD_X = 0
         for valor in pantalla[y]:
            if valor != IGNORE_VALUES:
               a, b = Consecutivos_Horiz(COORD_X, COORD_Y, pantalla, ANCHO_MAPA)
               c, d = Consecutivos_Vert(COORD_X, COORD_Y, pantalla, ALTO_MAPA)
               horizontales[COORD_Y][COORD_X] = len(b)
               verticales[COORD_Y][COORD_X] = len(d)
            COORD_X += 1
         COORD_Y += 1

      # Una vez construida la tabla, buscar la posicion X,Y que
      # tiene el valor mas alto y codificarla
      max_hx, max_hy, maxh_v = Coordenadas_Mayor_Valor( horizontales )
      max_vx, max_vy, maxv_v = Coordenadas_Mayor_Valor( verticales )

      # Codificar con horizontal o vertical segun cual sea el mayor
      if maxh_v >= maxv_v:
         if agrupar_xy == 0:
            mapa_codificado_h.append( max_hx )
            mapa_codificado_h.append( max_hy )
         else:
            mapa_codificado_h.append( (max_hx*16) + max_hy )
         a, b = Consecutivos_Horiz(max_hx, max_hy, pantalla, ANCHO_MAPA)
         pantalla = Borrar_Consecutivos( pantalla, a )
         mapa_codificado_h.extend( b )
         mapa_codificado_h.append( 255 )
      else:
         if agrupar_xy == 0:
            mapa_codificado_v.append( max_vx )
            mapa_codificado_v.append( max_vy )
         else:
            mapa_codificado_h.append( (max_vx*16) + max_vy )
         c, d = Consecutivos_Vert(max_vx, max_vy, pantalla, ALTO_MAPA)
         pantalla = Borrar_Consecutivos( pantalla, c )
         mapa_codificado_v.extend( d )
         mapa_codificado_v.append( 255 )

   # Sacamos las codificaciones en orden: primero horizontales, luego 254
   # tras eliminar el 255 final de las horizontales, y luego verticales.
   if mapa_codificado_h != []:
      mapa_codificado.extend(mapa_codificado_h[:-1])

   mapa_codificado.append( 254 )

   if mapa_codificado_v != []:
      mapa_codificado.extend(mapa_codificado_v)

   return mapa_codificado


#-----------------------------------------------------------------------
def Imprimir_Resultados( codificacion, mapa_codificado ):
   print " ; Flag codificacion:", codificacion, "-a" * agrupar_xy
   print " ; Resultado:", len(mapa_codificado), "Bytes"
   # Imprimimos los resultados de la codificacion
   CONTADOR_DB = -1
   for valor in mapa_codificado:
      CONTADOR_DB += 1
      if CONTADOR_DB == 0:     
         print " DB", str(valor),
      elif CONTADOR_DB == 11: 
         print ",", str(valor)
         CONTADOR_DB = -1
      else:
         print ",", str(valor),


#-----------------------------------------------------------------------
if __name__ == '__main__':

   # Variables que utilizaremos 
   pantalla = []
   COORD_X = 0
   COORD_Y = 0

   # Comprobar numero de argumentos + recoger y validar parametros:
   if len( sys.argv ) < 3:
      Uso()

   if "-a" in sys.argv:
      agrupar_xy = 1
      args = [ arg for arg in sys.argv if arg != '-a' ]
   else:
      args = sys.argv[:]

   if args[1][0] == '-':
      codificacion=args[1]
      fichero=args[2]
   elif args[2][0] == '-':
      codificacion=args[2]
      fichero=args[1]
   else:
      Uso()

   if codificacion[1] not in "bhvm":
      Uso()

   # Abrir el fichero de pantalla:
   try:
      fich = open( fichero )
   except:
      print "No se pudo abrir ", sys.argv[1]
      sys.exit(0)

   # Procesar el fichero "linea a linea"
   for linea in fich.readlines():

     pantalla.append( [] )

     # Eliminamos todo lo que no sean numeros, coma, y retorno de carro
     linea = filter(lambda c: c in "0123456789," + chr(10) + chr(13), linea)

     # Si encontramos una coma en la linea, procesarla:
     if ',' in linea:

        # Partimos la linea en valores separados por comas:
        linea = linea.strip()
        rows = linea.split(',')
        if len(rows) != ANCHO_MAPA:
          print "ERROR: Ancho =", len(rows), "valores. Esperados =", ANCHO_MAPA
          print "Finalizando programa: Por fvor corrija el fichero de datos."
          sys.exit(2)

        rows = [int(value) for value in rows]
        pantalla[ COORD_Y ].extend( rows )

        COORD_Y += 1
   # Fin lectura datos fichero

   if COORD_Y != ALTO_MAPA:
      print "ERROR: Alto =", COORD_Y+1, "lineas. Esperados =", ALTO_MAPA
      print "Finalizando programa: Por fvor corrija el fichero de datos."
      sys.exit(2)

   if codificacion in [ "-h", "-v", "-b" ]:
      mapa_codificado = Codificacion_Horiz_o_Vert( pantalla )
   elif codificacion == '-m':
      mapa_codificado = Codificacion_Mixta( pantalla )

   # Acabamos el mapa con el valor de fin de mapa
   mapa_codificado.append( 255 )

   # Imprimimos los resultados
   Imprimir_Resultados( codificacion, mapa_codificado)




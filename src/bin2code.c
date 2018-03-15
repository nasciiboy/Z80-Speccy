#include <stdio.h>
#include <stdlib.h>

#define MAXBYTE  20

/* 0=ASM, 1=C, 2=PASCAL */

//---------------------------------------------------------------------------

char cabeceras[4][80] = {
 "\r\n;  File created with  BIN2CODE  v1.0  by  NOP of Compiler SoftWare \r\n\r\n",
 "\r\n/* File created with  BIN2CODE  v1.0  by  NOP of Compiler SoftWare */\r\n\r\n",
 "\r\n{  File created with  BIN2CODE  v1.0  by  NOP of Compiler SoftWare  }\r\n\r\n",
 "\r\n;  File created with  BIN2CODE  v1.0  by  NOP of Compiler SoftWare \r\n\r\n"
			};

char lenguaje = 0;
char txtbyte[4][5] = { "DB  " ,   "   " ,   "   ", "DEFB" };
char txtword[4][5] = { "DW  " ,   "   " ,   "   ", "DEFW" };

char numdebyte = 0;
char haylabel = 0;
long longi = 0;
unsigned long f;
unsigned char tecla, car, bucle=1;

FILE *fpin;
FILE *fpout;

//---------------------------------------------------------------------------

long filesize(FILE *);
void DoByte( unsigned char, FILE *);
void DoHexByte( unsigned char, FILE *);
void Mensaje( void );
int file_exists(char *);
void ErrorIn( char *);



//---------------------------------------------------------------------------
int main( int argc, char *argv[] )
{

 if( argc < 3 )
	 Mensaje();

 if( argc > 3 )
 {
   if( argv[3][0] == 'C' || argv[3][0] == 'c' )      lenguaje = 1;
   else if( argv[3][0] == 'P' || argv[3][0] == 'p' ) lenguaje = 2;
   else if( argv[3][0] == 'z' || argv[3][0] == 'Z' ) lenguaje = 3;
 }

 if( argc > 4 ) haylabel=1;

printf("\r\nBIN2CODE v1.0             By NoP of Compiler SoftWare\r\n\r\n");

 fpin = fopen(argv[1], "rb");
  if( fpin == NULL ) ErrorIn(argv[1]);

 if( file_exists( argv[2] )  )
  {
   printf("File %s exists. Overwrite, Append or Cancel? [o-a-c] ", argv[2]);
   tecla = getchar();
   printf("\r\n");

   if(tecla == 'o' || tecla == 'O' )
    {
       fpout = fopen(argv[2], "wt");
	 if( fpout == NULL )  ErrorIn(argv[2]);
    }
      if(tecla == 'a' || tecla == 'A' )
    {
       fpout = fopen(argv[2], "a+t");
	 if( fpout == NULL )  ErrorIn(argv[2]);
    }

	  if(tecla == 'c' || tecla == 'C' )
    {
	exit(2);
    }
  }

 else {
 fpout = fopen(argv[2], "wt");
  if( fpout == NULL )  ErrorIn(argv[2]);
      }

 fprintf(fpout,"%s",cabeceras[lenguaje]);

 longi = filesize(fpin);

     if( lenguaje == 1 )
      {
      if( haylabel == 0 ) fprintf(fpout,"unsigned char Bindata[ %ld ] = { ",longi);
      else fprintf(fpout,"unsigned char %s[ %ld ] = { ",argv[4], longi);
     }
     else if( lenguaje == 2 )
     {

     if( haylabel == 0 ) fprintf(fpout,"Const\n\r   Bindata: Array[1..%ld] Of Byte = ( ",longi);
      else fprintf(fpout,"Const\n\r   %s: Array[1..%ld] Of Byte = ( ",argv[4],longi);
     }
     else
     {
     if( haylabel == 0 )
      {
      fprintf(fpout,"\r\nBINDATASIZE   EQU   %ld\r\n\r\n",longi);
      fprintf(fpout,"BINDATA LABEL BYTE");
      }
     else {
      fprintf(fpout,"\r\n%sSIZE   EQU   %ld\r\n\r\n",argv[4],longi);
      fprintf(fpout,"%s LABEL BYTE",argv[4]);
	  }
      }

  for(f=0; f<longi; f++)
     DoByte( fgetc(fpin), fpout );
/*
     if( lenguaje == 0 || lenguaje == 3 )
     {
         if( numdebyte != 0 )
         { 
              fseek( fpout, -1, SEEK_CUR );
              fprintf(fpout,"\r\n");
         }
         else  fprintf(fpout,"\r\n");
     }
*/
     if( lenguaje == 1 )
       fprintf(fpout,"\r\n };\r\n ");

     if( lenguaje == 2 )
       fprintf(fpout,"\r\n );\r\n ");

   fcloseall();
   printf("%ld bytes from file %s converted to %s.\r\n",longi, argv[1], argv[2]);
   return(0);

}



/*---------------------------------------------------------------------------
 DoByte();
 Copia un byte en el fichero con formateo autom tico a MAXBYTE columnas.
---------------------------------------------------------------------------*/

void DoByte( unsigned char num, FILE *fp )
{
    if( numdebyte == 0 )
        fprintf(fp,"\r\n   %s ",txtbyte[ lenguaje ]);

    if( numdebyte == 0 ) 
    {
      if( f == (longi-1) ) 
       fprintf(fp,"%u", num );
      else
       fprintf(fp,"%u,", num );
    }

    else 
    {
       if( numdebyte == MAXBYTE-1 )
       {  
           if( lenguaje== 0 || lenguaje==3 ) fprintf(fp,"%u", num );
           else
           {
              if( f >= (longi-1) ) 
                 fprintf(fp,"%u", num );
              else
                 fprintf(fp,"%u,", num );
           }
        }
        else 
        {
           if( f >= (longi-1) ) 
               fprintf(fp,"%u", num );
           else
              fprintf(fp,"%u,", num );
	      }
    }
    numdebyte = (numdebyte + 1) % MAXBYTE;
}

//---------------------------------------------------------------------------
long filesize(FILE *stream)
{
   long curpos, length;

   curpos = ftell(stream);
   fseek(stream, 0L, SEEK_END);
   length = ftell(stream);
   fseek(stream, curpos, SEEK_SET);
   return length;
}


//---------------------------------------------------------------------------
void ErrorIn( char *name )
{
 printf("\a\r\nError opening the file <%s>.\r\n",name);
 exit(1);
}


int file_exists(char *filename)
{
  return (access(filename, 0) == 0);
}

//---------------------------------------------------------------------------

void Mensaje()
{

printf("\r\nBIN2CODE v1.1             By NoP of Compiler SoftWare\r\n\r\n");
printf("Converts binary files to ASM/C/PASCAL/ASM_Z80 source code in order to use it as\r\n");
printf("data in the program. Converts the binary data -ex. MYPAL.RGB (768 bytes)-\r\n");
printf("to a text file like MYPAL.C which contains the data in a char array.\r\n");
printf("Supports C, PASCAL and ASM arrays and can append the data to existing files.\r\n\r\n");
printf("Usage: BIN2CODE <infile> <outfile>   [ <language> <label>  ]\r\n\r\n");
printf(" <infile>       The binary file you want to convert.\r\n");
printf(" <outfile>      The text file you want to create/append to.\r\n");
printf(" <language>     The language of the text file: A=ASM (def), C=C, P=PASCAL, Z=Z80\r\n");
printf(" <label>        The name of the array which'll contain the data.(def=BinData)\r\n");
printf("\r\nExamples:\r\n");
printf("           BIN2CODE colors.pal file.asm\r\n");
printf("           BIN2CODE colors.pal file.c c Datos\r\n");
printf("           BIN2CODE colors.pal file.pas p\r\n");
printf("           BIN2CODE colors.pal file.asm z Sprite_Nave\r\n\r\n");

 exit(2);

}


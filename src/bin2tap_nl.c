/*   bin2tap_nl.c : Quick 'n' dirty mym to tap converter
 *   Modified so that the BASIC loader is not added (sromero)
 *   Usage: bin2tap [binfile] [tapfile]
 *
 *   Dominic Morris  - 08/02/2000 - tapmaker
 *   Stefano Bodrato - 03/12/2000 - bin2tap
 *   Stefano Bodrato - 29/05/2001 - ORG parameter adder
 *   Santiago Romero - 04/10/2007 - BASIC loader not added
 *   gcc -o bin2tap_nl bin2tap_nl.c
 */
#include <stdio.h>
#include <stdlib.h>

unsigned char parity;
void writebyte(unsigned char, FILE *);
void writeword(unsigned int, FILE *);

int main(int argc, char *argv[])
{
   char   name[11], mybuf[20];
   FILE   *fpin, *fpout;
   int    c,   i, len, pos=32768;

   if ((argc < 3 )||(argc > 4 )) {
      fprintf(stdout,"Usage: %s [code file] [tap file] <ORG location>\n",argv[0]);
      exit(1);
   }
   
   if (argc == 4 ) { pos=atoi(argv[3]); }

   if ( (fpin=fopen(argv[1],"rb") ) == NULL ) {
      fprintf(stderr,"Can't open input file\n");
      exit(1);
   }

   if   (fseek(fpin,0,SEEK_END)) {   // get input file size
      fprintf(stderr,"Couldn't determine size of file\n");
      fclose(fpin);
      exit(1);
   }
   len=ftell(fpin);
   fseek(fpin,0L,SEEK_SET);

   if ( (fpout=fopen(argv[2],"wb") ) == NULL ) {
      fprintf(stdout,"Can't open output file\n");
      exit(1);
   }

   /* M/C program, Write out the code header file */
   writeword(19,fpout);   /* Header len */
   writebyte(0,fpout);   /* Header is 0 */
   parity=0;
   writebyte(3,fpout);   /* Filetype (Code) */

   if (strlen(argv[1]) >= 10 ) {   // filename
      strncpy(name,argv[1],10);
   } else {
      strcpy(name,argv[1]);
      strncat(name,"          ",10-strlen(argv[1]));
   }
   for   (i=0;i<=9;i++)
      writebyte(name[i],fpout);
   writeword(len,fpout);
   writeword(pos,fpout);   /* load address */
   writeword(0,fpout);   /* offset */
   writebyte(parity,fpout);

   writeword(len+2,fpout);   /* Length of next block */
   parity=0;
   writebyte(255,fpout);   /* Data... */
   for (i=0; i<len;i++) {
      c=getc(fpin);
      writebyte(c,fpout);
   }
   writebyte(parity,fpout);
   fclose(fpin);
   fclose(fpout);
}

//------------------------------------------------------------
void writeword(unsigned int i, FILE *fp)
{
   writebyte(i%256,fp);
   writebyte(i/256,fp);
}

void writebyte(unsigned char c, FILE *fp)
{
   fputc(c,fp);
   parity^=c;
}


#include <stdio.h>
#define RLE_LIMIT 192


#define uint unsigned int

uint file_length(FILE *f);
uint RLE_compress( unsigned char *src, unsigned char *dst, 
                  char scanline_width, uint length );
uint RLE_decompress( unsigned char *src, unsigned char *dst, 
                   uint lenght );


//-------------------------------------------------------------------------------------
int main( int argc, char *argv[])
{
  unsigned char source[(32*192)+(32*25)];
  unsigned char dest[(32*192)+(32*25)];
  FILE *fp, *out;
  uint dest_size = 0;
  uint org_size=0;
  uint i;

  // Check number of arguments in command line
  if( argc < 4 )
  {
    printf("Usage: \n");
    printf("Compress:   rlecrunch a input.scr output.scr\n");
    printf("Decompress: rlecrunch x input.scr output.scr\n");
    return(-1);
  }
 
  // open input file
  fp = fopen( argv[2], "rb" );
  if( fp == NULL )
  { 
     printf("Can't open %s for reading.\n", argv[2] ); 
     return(-1); 
  }
  else
  {
     org_size = file_length( fp );
     fread( source, 1, org_size, fp );
  }

  // open output file
  out = fopen( argv[3], "wb");
  if( out == NULL )
  { 
     printf("Can't open %s for writing.\n", argv[3] ); 
     return(-1); 
  }

  // do the job:
  if( argv[1][0] == 'a' )
     dest_size = RLE_compress( source, dest, 64, org_size );
  else
     dest_size = RLE_decompress( source, dest, org_size );

  // show info on the screen ...
  printf("Output size: %d\n", dest_size ); 

  // write the data to the output file
  fwrite( dest, 1, dest_size, out );

  fclose(fp);
  fclose(out);
  return(0);
}



//-------------------------------------------------------------------------------------
uint RLE_compress( unsigned char *src, unsigned char *dst, 
                           char scanline_width, uint length )
{
  uint offset, dst_pointer;
  uint bytecounter, width;
  unsigned char b1, b2, data;

  dst_pointer = offset = 0;
  bytecounter = 1;
  width = 0;

  b1 = src[offset++];

  do 
  {
     b2 = src[offset++];
     width++;
 
     while ((b2 == b1) &&
            (bytecounter < scanline_width-1 ) &&
            (width < scanline_width-1))
     {
         bytecounter++;
         b2 = src[offset++];
         width++;
     }
     if (width >= scanline_width)
     {
        offset += scanline_width-width;
        width = 0;
     }
     if (bytecounter != 1)
     {
        data = RLE_LIMIT+bytecounter;
        dst[dst_pointer++] = data;
        dst[dst_pointer++] = b1;
     }
 
     if (bytecounter == 1)
     {
        if (b1 < RLE_LIMIT) 
        {
          dst[dst_pointer++] = b1;
        }
        else
        {
          data = RLE_LIMIT+1;
          dst[dst_pointer++] = data;
          dst[dst_pointer++] = b1;
        }
     }

     bytecounter = 1;
     b1 = b2;
  } 
  while (offset <= length);

  return(dst_pointer);
}



//-------------------------------------------------------------------------------------
uint RLE_decompress( unsigned char *src, unsigned char *dst, 
                             uint length )
{
  int offset, dst_pointer, i;
  unsigned char b1, b2, j;

  dst_pointer = offset = 0;

  for( i=0; i<length; i++)
  {
     b1 = src[offset++];

     if( b1 > RLE_LIMIT )
     {
        b2 = src[offset++];
        i++;
        for( j=0; j<(b1-RLE_LIMIT); j++ )
            dst[dst_pointer++] = b2;
     }
     else
        dst[dst_pointer++] = b1;
  }

  return(dst_pointer);
}


//-------------------------------------------------------------------------------------
uint file_length(FILE *f)
{
  int pos, end;

  pos = ftell (f);
  fseek (f, 0, SEEK_END);
  end = ftell (f);
  fseek (f, pos, SEEK_SET);

  return end;
}

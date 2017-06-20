#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define EN0 0 /* MODE == encrypt */
#define DE1 1 /* MODE == decrypt */
#define useDkey(a) use3key((a));
#define cpDkey(a) cp3key((a));
void deskey(unsigned char *key,short edf);
static void cookey(register unsigned long *raw1);
void cpkey(register unsigned long *into);
void usekey(register unsigned long *from);
void des(unsigned char *inblock, unsigned char *outblock);
static void scrunch(register unsigned char *outof,register unsigned long *into);
static void unscrun(register unsigned long *outof,register unsigned char *into);
static void desfunc(register unsigned long *block, register unsigned long *keys);
void des2key(unsigned char *hexkey, short mode);
void Ddes(unsigned char *from,unsigned char *into);
void D2des(unsigned char *from, unsigned char *into);
void makekey(register char *aptr, register unsigned char *kptr);
void cp2key(register unsigned long *into);
void use2key(register unsigned long *from);
void des3key(unsigned char *hexkey,short mode);
void cp3key(register unsigned long *into);
void use3key(register unsigned long *from);
static void D3des(unsigned char *from, unsigned char *into);
void make3key(register char *aptr, register unsigned char *kptr);
void Des3(unsigned char* in,unsigned char * out,unsigned char *key,int key_length_in,short mode);


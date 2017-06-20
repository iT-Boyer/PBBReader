// SM3.cpp : Defines the entry point for the console application.
//


/***************************************************************************
* File name    :	SM3c.c
* Function     :	SM3 function
* Author       : 	 
* Date         :	2011/03/ 
* Version      :    v1.0
* Description  :     
* ModifyRecord :
****************************************************************************/
//#include "stdafx.h"
//#include <stdafx.h>
#include "SM3.h"



//using std::string;


static void SM3Transform(UINT32 stateIV[8], UINT32 T[64], UINT8 block[64]);
static void Extend(UINT32 *output,UINT32 *output1,UINT32 *input,UINT32 len);
static void Encode(UINT8 *output,UINT32 *input,UINT32 len);
static void Encode2(UINT8 *output,UINT32 *input,UINT32 len);
static void Decode(UINT32 *output,UINT8 *input,UINT32 len);


static UINT8 PADDING[64] = {
  0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};


/* ROTATE_LEFT rotates x left n bits. 
*/
#define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32-(n))))


/*Substi_P0,Substi_P1,Bool_FF and Bool_GG are basic SM3 functions.
*/
#define Substi_P0(x) ((x) ^ ROTATE_LEFT((x), 9) ^ ROTATE_LEFT((x), 17))
#define Substi_P1(x) ((x) ^ ROTATE_LEFT((x), 15) ^ ROTATE_LEFT((x), 23))
#define Bool_FF(x, y, z, j) (((j) < 16) ? ((x) ^ (y) ^ (z)) : (((x) & (y)) | ((x) & (z)) | ((y) & (z))))
#define Bool_GG(x, y, z, j) (((j) < 16) ? ((x) ^ (y) ^ (z)) : ((x) & (y) | ((0xffffffff^x) & (z))))






/***************************************************************************
* Subroutine:	SM3_Init
* Function:		SM3 initialization. Begins an SM3 operation, writing a new context.
* Input:		context-SM3 Context struct
* Output:		None;
* Description:	 
* Date:			2011.03. 
* ModifyRecord:
* *************************************************************************/ 
void SM3_Init (SM3_CONTEXT *context)
{
	int j = 0;
	context->count[0] = context->count[1] = 0;

	/*
		Load magic initialization constants.
	*/
	context->stateIV[0] = 0x7380166f;
	context->stateIV[1] = 0x4914b2b9;
	context->stateIV[2] = 0x172442d7;
	context->stateIV[3] = 0xda8a0600;
	context->stateIV[4] = 0xa96f30bc;
	context->stateIV[5] = 0x163138aa;
	context->stateIV[6] = 0xe38dee4d;
	context->stateIV[7] = 0xb0fb0e4e;
	/*
		Load initial constant list T. 
	*/
	for (j=0;j<=15;j++)
	{
	context->T[j]=0x79cc4519;
	}
	for(j=16;j<=63;j++)
	{
		context->T[j]=0x7a879d8a;
	}
}


/***************************************************************************
* Subroutine:	SM3_Update
* Function:		SM3 block update operation. Continues an SM3 message-digest
	 operation, processing another message block, and updating the
	 context
* Input:		context-SM3 Context struct
                input- the data will hash
                inputLen- the data length
* Output:		None;
* Description:	 
* Date:			2011.03. 
* ModifyRecord:
* *************************************************************************/ 
void SM3_Update(
SM3_CONTEXT *context,              /* context */
UINT8 *input,           /* input block */
UINT32 inputLen)          /* length of input block */
{
	UINT32 i, index, partLen;

	/* Compute number of bytes mod 64 */
	index = (UINT32)((context->count[0] >> 3) & 0x3F);

	/* Update number of bits */
	if((context->count[0] += ((UINT32)inputLen << 3)) < ((UINT32)inputLen << 3))
		context->count[1]++;

	context->count[1] += ((UINT32)inputLen >> 29);

	partLen = 64 - index;

	/* Transform as many times as possible.
	 */
	if(inputLen >= partLen)
	{
		memcpy(&context->buffer[index], input, partLen);
		SM3Transform(context->stateIV, context->T, context->buffer);

		for(i = partLen; i + 63 < inputLen; i += 64)
			SM3Transform(context->stateIV, context->T,&input[i]);

		index = 0;
	}
	else
		i = 0;

	/* Buffer remaining input */
	memcpy(&context->buffer[index], &input[i], inputLen-i);
}


/***************************************************************************
* Subroutine:	SM3_Final
* Function:		SM3 finalization. Ends an SM3 message-digest operation, writing the
	 the message digest and zeroizing the context. 
* Input:		context-SM3 Context struct
* Output:		digest- the message digest;
* Description:	 
* Date:			2011.03. 
* ModifyRecord:
* *************************************************************************/ 
void SM3_Final (
SM3_CONTEXT *context,               /* context */
UINT8 digest[32])       /* message digest */

{
	UINT8 bits[8];
	UINT32 index, padLen;

	/* Save number of bits */
	Encode(bits, context->count, 8);

	/* Pad out to 56 mod 64.
	 */
	index = (UINT32)((context->count[0] >> 3) & 0x3f);
	padLen = (index < 56) ? (56 - index) : (120 - index);
	SM3_Update(context, PADDING, padLen);

	/* Append length (before padding) */
	SM3_Update(context, bits, 8);

	/* Store state in digest */
	Encode2(digest, context->stateIV, 32);

	/* Zeroize sensitive information. */
	/*for(int i=0;i<8;i++)
	{
		printf("%08X  ",context->stateIV[i]);
	}
	printf("\n");*/

	memset(context, 0, sizeof(*context));
}


UINT32 rotate_left(UINT32 x, UINT32 n)
{
    if (n<=32) {
        return (((x) << (n)) | ((x) >> (32-(n))));
    }else{
        UINT32 ii;
        //int b = sizeof(int);
        ii =(x)<<(n - 32);
        UINT32 kk = ( 32 - (n) )% 32;
        UINT32 jj = ((x) >> kk);
        UINT32 hh = ii|jj;
        return hh;
    }
    
}
void  SM3Transform (UINT32 stateIV[8],UINT32 T[64],UINT8 block[64])
{
	UINT32 i,j,n;
	UINT32 ss1, ss2, tt1, tt2, w[16], w0[68], w1[64];
	UINT32 a = stateIV[0], b = stateIV[1], c = stateIV[2], d = stateIV[3],
    e = stateIV[4], f = stateIV[5], g = stateIV[6], h = stateIV[7] ;
    
    
	Decode(w, block, 64);
	Extend(w0, w1, w, 16);
	/* Begin compressing.*/
	n = (sizeof(w)<<3)>>9;//1
	for(i = 0; i < n; i++)
	{
		for(j = 0; j < 64; j++)
		{

            ss1 = ROTATE_LEFT(a, 12);
            ss1+=e;
            if (j >=33) {
                ss1 += rotate_left(T[j], j);
            }else{
                ss1+=ROTATE_LEFT(T[j], j);
            }
            
			ss1 = ROTATE_LEFT(ss1, 7);
			ss2 = ss1 ^ ROTATE_LEFT(a, 12);
			tt1 = Bool_FF(a, b, c, j) + d + ss2 + w1[j];
			tt2 = Bool_GG(e, f, g, j) + h + ss1 + w0[j];
			d = c;
			c = ROTATE_LEFT(b, 9);
			b = a;
			a = tt1;
			h = g;
			g = ROTATE_LEFT(f,19);
			f = e;
			e = Substi_P0(tt2);
            // printf("~~~%d  ss1 = %u,ss2 = %u,tt1 = %u,tt2 = %u, c= %u, g=%u, e=%u a=%u\n", j, ss1,ss2,tt1,tt2, c, g, e,a);
		}
        
        
        
		stateIV[0] = a ^ stateIV[0];
		stateIV[1] = b ^ stateIV[1];
		stateIV[2] = c ^ stateIV[2];
		stateIV[3] = d ^ stateIV[3];
		stateIV[4] = e ^ stateIV[4];
		stateIV[5] = f ^ stateIV[5];
		stateIV[6] = g ^ stateIV[6];
		stateIV[7] = h ^ stateIV[7];
	}
	/* Zeroize sensitive information. */
    
	memset(w, 0, sizeof(w));
}



/***************************************************************************
* Subroutine:	Extend
* Function:		Extend input (UINT32) into output and ouput1 (UINT32). Assumes len is

	 a multiple of 4..
* Input:		None
* Output:		None;
* Description:	 
* Date:			2011.03. 
* ModifyRecord:
* *************************************************************************/ 
void Extend(UINT32 *output,UINT32 *output1,UINT32 *input,UINT32 len)
{
	UINT32 i, j;
	for(j = 0; j < len; j++)
	{
		output[j]=input[j];
	}
	for(j = len; j < 68; j++)
	{
		output[j] = Substi_P1((output[j-len]) ^ (output[j-9]) ^ (ROTATE_LEFT((output[j-3]),15))) ^ 
		(ROTATE_LEFT((output[j-13]),7)) ^ (output[j-6]);
	}
	for(i = 0; i < 64; i++)
	{
		output1[i] = output[i] ^ output[i+4];
	}
}


/***************************************************************************
* Subroutine:	Encode
* Function:		Encodes input (UINT32) into output (UINT8). Assumes len is
	 a multiple of 4..
* Input:		None
* Output:		None;
* Description:	 
* Date:			2011.03. 
* ModifyRecord:
* *************************************************************************/ 
static void Encode(UINT8 *output,UINT32 *input,UINT32 len)
{
	UINT32 i, j;
	i = len/4-1;

	for(j = 0; j < len; i--, j += 4)
	{
		output[j+3] = (UINT8)(input[i] & 0xff);
		output[j+2] = (UINT8)((input[i] >> 8) & 0xff);
		output[j+1] = (UINT8)((input[i] >> 16) & 0xff);
		output[j] = (UINT8)((input[i] >> 24) & 0xff);
	}
}
 
/***************************************************************************
* Subroutine:	Encode2
* Function:		Encodes input (UINT32) into output (UINT8). Assumes len is
	 a multiple of 4..
* Input:		None
* Output:		None;
* Description:	 
* Date:			2011.03. 
* ModifyRecord:
* *************************************************************************/ 
static void Encode2(UINT8 *output,UINT32 *input,UINT32 len)
{
	UINT32 i, j;
	int k = len/4;

	for(i=0,j = 0; j < len && i < k; i++, j += 4)
	{
		output[j+3] = (UINT8)(input[i] & 0xff);
		output[j+2] = (UINT8)((input[i] >> 8) & 0xff);
		output[j+1] = (UINT8)((input[i] >> 16) & 0xff);
		output[j] = (UINT8)((input[i] >> 24) & 0xff);
	}
}
/***************************************************************************
* Subroutine:	Decode
* Function:		Decodes input (UINT8) into output (UINT32). Assumes len is
	 a multiple of 4.
* Input:		None
* Output:		None;
* Description:	 
* Date:			2011.03. 
* ModifyRecord:
* *************************************************************************/ 
static void Decode(UINT32 *output,UINT8 *input,UINT32 len)
{
	UINT32 i, j;

	for(i = 0, j = 0; j < len; i++, j += 4)
		output[i] = (((UINT32)input[j]) << 24) | (((UINT32)input[j+1]) << 16) | 
					 (((UINT32)input[j+2]) << 8) | ((UINT32)input[j+3]);
}

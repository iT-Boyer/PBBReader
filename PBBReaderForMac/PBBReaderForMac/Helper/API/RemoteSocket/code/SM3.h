/***************************************************************************************
* File name    :	SM3.h
* Function     :	The header of SM3c.c
* Author       : 	 
* Date         :	2011/03/
* Version      :	v1.0
* Description  :
* ModifyRecord :
*****************************************************************************************/
#ifndef _SM3_H_
#define _SM3_H_

#include <stdio.h>
#include <memory.h>


#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned int UINT32;
typedef unsigned char UINT8;

#define LENGTH_BYTES 96

/*SM3 context.*/
typedef struct
{
	UINT32 stateIV[8];	/*state (ABCDEFGH)*/
	UINT32 count[2];	/*number of bits, modulo 2^64 (lsb first) */
	UINT32 T[64];		/* the initial const list T.*/
	UINT8 buffer[64];	/* input buffer */
}SM3_CONTEXT,*PSM3_CONTEXT;


void SM3_Init(SM3_CONTEXT *pCtx);
void SM3_Update(SM3_CONTEXT *pCtx, UINT8 *pData, UINT32 lDataLen);
void SM3_Final(SM3_CONTEXT *pCtx,UINT8 Result[32]);

#ifdef __cplusplus
}
#endif
#endif	/*_SM3_H_*/

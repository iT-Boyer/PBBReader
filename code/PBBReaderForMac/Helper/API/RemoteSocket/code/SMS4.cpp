/**
 * @file SMS4.cpp
 * @brief SMS4算法实现文件
 * @author
 * @date
 * @version
*/

/* define SMS4DBG flag for debug these code */


/* reserved for saving interface */

#include "sms4.h"
#include "string.h"



/*=============================================================================
** private function:
**   look up in SboxTable and get the related value.
** args:    [in] inch: 0x00~0xFF (8 bits unsigned value).
**============================================================================*/
static uint8 SMS4Sbox(uint8 inch)
{
	uint8 *pTable = (uint8 *)SboxTable;
	uint8 retVal = (uint8)(pTable[inch]);

	return retVal;
}

/*=============================================================================
** private function:
**   "T algorithm" == "L algorithm" + "t algorithm".
** args:    [in] a: a is a 32 bits unsigned value;
** return: c: c is calculated with line algorithm "L" and nonline algorithm "t"
**============================================================================*/
static uint32 SMS4Lt(uint32 a)
{
	uint32 b = 0;
	uint32 c = 0;
	uint8 a0 = (uint8)(a & SMS4MASK0);
	uint8 a1 = (uint8)((a & SMS4MASK1) >> 8);
	uint8 a2 = (uint8)((a & SMS4MASK2) >> 16);
	uint8 a3 = (uint8)((a & SMS4MASK3) >> 24);
	uint8 b0 = SMS4Sbox(a0);
	uint8 b1 = SMS4Sbox(a1);
	uint8 b2 = SMS4Sbox(a2);
	uint8 b3 = SMS4Sbox(a3);

	b =b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
	c =b^(SMS4CROL(b, 2))^(SMS4CROL(b, 10))^(SMS4CROL(b, 18))^(SMS4CROL(b, 24));

	return c;
}

/*=============================================================================
** private function:
**   Calculating round encryption key.
** args:    [in] a: a is a 32 bits unsigned value;
** return: ENRK[i]: i{0,1,2,3,...31}.
**============================================================================*/
static uint32 SMS4CalciRK(uint32 a)
{
	uint32 b = 0;
	uint32 rk = 0;
	uint8 a0 = (uint8)(a & SMS4MASK0);
	uint8 a1 = (uint8)((a & SMS4MASK1) >> 8);
	uint8 a2 = (uint8)((a & SMS4MASK2) >> 16);
	uint8 a3 = (uint8)((a & SMS4MASK3) >> 24);
	uint8 b0 = SMS4Sbox(a0);
	uint8 b1 = SMS4Sbox(a1);
	uint8 b2 = SMS4Sbox(a2);
	uint8 b3 = SMS4Sbox(a3);

	b = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
	rk = b^(SMS4CROL(b, 13))^(SMS4CROL(b, 23));

	return rk;
}

/*=============================================================================
** private function:
**   Calculating round encryption key.
** args:    [in] ulflag: if 0: not calculate DERK , else calculate;
** return: NONE.
**============================================================================*/
static void SMS4CalcRK(uint32 ulflag)
{
	uint32 k[36];
	uint32 i = 0;

	k[0] = MK[0]^FK[0];
	k[1] = MK[1]^FK[1];
	k[2] = MK[2]^FK[2];
	k[3] = MK[3]^FK[3];

	for(; i<32; i++)
	{
		k[i+4] = k[i] ^ (SMS4CalciRK(k[i+1]^k[i+2]^k[i+3]^CK[i]));
		ENRK[i] = k[i+4];
	}

	if (ulflag != 0x00) 
	{
		for (i=0; i<32; i++) 
		{
				DERK[i] = ENRK[31-i];
		}
	}
}

/*=============================================================================
** private function:
**   "T algorithm" == "L algorithm" + "t algorithm".
** args:    [in] a: a is a 32 bits unsigned value.
**============================================================================*/
static uint32 SMS4T(uint32 a)
{
	return (SMS4Lt(a));
}

/*=============================================================================
** private function:
** Calculating and getting encryption/decryption contents.
** args:    [in] x0: original contents;
** args:    [in] x1: original contents;
** args:    [in] x2: original contents;
** args:    [in] x3: original contents;
** args:    [in] rk: encryption/decryption key;
** return the contents of encryption/decryption contents.
**============================================================================*/
static uint32 SMS4F(uint32 x0, uint32 x1, uint32 x2, uint32 x3, uint32 rk)
{
	return (x0^SMS4Lt(x1^x2^x3^rk));
}

/*=============================================================================
** public function:
**   "T algorithm" == "L algorithm" + "t algorithm".
** args:    [in] ulkey: password defined by user(NULL: default encryption key);
** args:    [in] flag: if 0: not calculate DERK , else calculate;
** return ulkey: NULL for default encryption key.
**============================================================================*/
uint32 *SMS4SetKey(uint32 *ulkey, uint32 flag)
{
	if (ulkey != 0)
	{
		memcpy(MK, ulkey, sizeof(MK));
	}

	SMS4CalcRK(flag);

	return ulkey;
}

/*=============================================================================
** public function:
**   sms4 encryption algorithm.
** args:   [in/out] psrc: a pointer point to original contents;
** args:   [in] lgsrc: the length of original contents;
** args:   [in] derk: a pointer point to encryption/decryption key;
** return: pRet: a pointer point to encrypted contents.
**============================================================================*/
uint32 *SMS4EncryptOld(uint32 *psrc, uint32 lgsrc, uint32 rk[])
{
	uint32 *pRet = 0;
	uint32 i = 0;

	uint32 ulbuf[36];

	uint32 ulCnter = 0;
	uint32 ulTotal = (lgsrc >> 4);


	if(psrc != 0)
	{
		pRet = psrc;
		/* !!!It's a temporary scheme: start!!! */
		/*========================================
		** 16 bytes(128 bits) is deemed as an unit.
		**======================================*/
		while (ulCnter<ulTotal) 
		{
			/* reset number counter */
			i = 0;

			/* filled up with 0*/
			memset(ulbuf, 0, sizeof(ulbuf));
			memcpy(ulbuf, psrc, 16);
#ifdef SMS4DBG0
			printf("0x%08x, 0x%08x, 0x%08x, 0x%08x, \n", 
						 ulbuf[0], ulbuf[1], ulbuf[2], ulbuf[3]);
#endif /* SMS4DBG0 */

			while(i<32)
			{
				ulbuf[i+4] = SMS4F(ulbuf[i], ulbuf[i+1], 
													 ulbuf[i+2], ulbuf[i+3], rk[i]);
#ifdef SMS4DBG0
							printf("0x%08x, \n", ulbuf[i+4]);
#endif /* SMS4DBG0 */
				i++;
			}

			/* save encrypted contents to original area */
			psrc[0] = ulbuf[35];
			psrc[1] = ulbuf[34];
			psrc[2] = ulbuf[33];
			psrc[3] = ulbuf[32];

			ulCnter++;
			psrc += 4;
		}
			/* !!!It's a temporary scheme: end!!! */
	}

	return pRet;
}

/*=============================================================================
** public function:
**   sms4 decryption algorithm.
** args:   [in/out] psrc: a pointer point to encrypted contents;
** args:   [in] lgsrc: the length of encrypted contents;
** args:   [in] derk: a pointer point to decryption key;
** return: pRet: a pointer point to decrypted contents.
**============================================================================*/
uint32 *SMS4Decrypt(uint32 *psrc, uint32 lgsrc, uint32 derk[])
{
	uint32 *pRet = 0;
	//uint32 i = 0;

	if(psrc != 0)
	{
		pRet = psrc;

		/* the same arithmetic, different encryption key sequence. */
		SMS4EncryptOld(psrc, lgsrc, derk);
	}

	return pRet;
}
uint32 *SMS4Encrypt(uint32 *psrc, uint32 lgsrc,uint32 flag)
{
	uint32 *pRet = 0;
	uint32 i = 0;
    i = sizeof(lgsrc);
	uint32 ulbuf[36];
i = sizeof(ulbuf);
	uint32 ulCnter = 0;
	uint32 ulTotal = (lgsrc >> 4);


	if(psrc != 0)
	{
		pRet = psrc;
		/* !!!It's a temporary scheme: start!!! */
		/*========================================
		** 16 bytes(128 bits) is deemed as an unit.
		**======================================*/
		while (ulCnter<ulTotal) 
		{
			/* reset number counter */
			i = 0;

			/* filled up with 0*/
			memset(ulbuf, 0, sizeof(ulbuf));
			memcpy(ulbuf, psrc, 16);
#ifdef SMS4DBG0
			printf("0x%08x, 0x%08x, 0x%08x, 0x%08x, \n", 
						 ulbuf[0], ulbuf[1], ulbuf[2], ulbuf[3]);
#endif /* SMS4DBG0 */

			while(i<32)
			{
				if (flag != 0x00)
				{
					ulbuf[i+4] = SMS4F(ulbuf[i], ulbuf[i+1], 
														ulbuf[i+2], ulbuf[i+3], ENRK[i]);
				}
				else
				{
					ulbuf[i+4] = SMS4F(ulbuf[i], ulbuf[i+1], 
														ulbuf[i+2], ulbuf[i+3], DERK[i]);
				}
#ifdef SMS4DBG0
							printf("0x%08x, \n", ulbuf[i+4]);
#endif /* SMS4DBG0 */
				i++;
			}

			/* save encrypted contents to original area */
			psrc[0] = ulbuf[35];
			psrc[1] = ulbuf[34];
			psrc[2] = ulbuf[33];
			psrc[3] = ulbuf[32];

			ulCnter++;
			psrc += 4;
		}
			/* !!!It's a temporary scheme: end!!! */
	}

	return pRet;
}

/*=============================================================================
** public function:
**   sms4 decryption algorithm.
** args:   [in/out] psrc: a pointer point to encrypted contents;
** args:   [in] lgsrc: the length of encrypted contents;
** args:   [in] derk: a pointer point to decryption key;
** return: pRet: a pointer point to decrypted contents.
**============================================================================*/
uint32 *SMS4Decrypt(uint32 *psrc, uint32 lgsrc)
{
	uint32 *pRet = 0;
	//uint32 i = 0;

	if(psrc != 0)
	{
		pRet = psrc;

		/* the same arithmetic, different encryption key sequence. */
		SMS4Encrypt(psrc, lgsrc, 0);
	}

	return pRet;
}
/**
 * @file HttpDes.cpp
 * @brief 用于跟http交互，别的地方没有用到，为了与公共模块兼容
 *		  添加该模块
 * @author
 * @date
 * @version
*/

#include "HttpDes.h"
#include "utility.h"

CHttpDes::CHttpDes()
{

}

CHttpDes::~CHttpDes()
{

}



int CHttpDes::des_ecb_pkcs7_encrypt(uchar* from, int nLength,  uchar * to, uchar key[])
{
	int nSize = nLength % 8 ?(nLength + 7) / 8 * 8 : nLength + 8;
	if(to == NULL)
	{
		//计算长度
		return nSize;
	}
	else
	{
		deskey(key,EN0);
		uchar endBuf[8];

		int i=0;
		for(; i < nSize; i+=8)
		{
			uchar* ps = NULL,* pd = NULL;
			if(nLength - i >= 8)
			{
				ps = from + i;
				pd = to + i;
			}
			else
			{
				memset(&endBuf, i + 8 - nLength, sizeof(endBuf));
				memcpy(&endBuf,from + i,nLength - i);
				ps = endBuf;
				pd = to + i;
			}

			des(ps,pd);

		}


		return i;
	}
}


int CHttpDes::des_ecb_pkcs7_decrypt(uchar* from, int nLength,  uchar * to, uchar key[])
{
	if(nLength % 8)
		return 0;    //数据不正确

	deskey(key,DE1);
	int i = 0;
	for(; i < nLength; i+=8)
	{
		if(nLength - i > 8)
		{
			des(from + i,to + i);
		}
		else
		{
			uchar endBuf[8];
			des(from + i,endBuf);

			//去除数据尾
			uchar chEnd = endBuf[7];
			if(chEnd > 0 && chEnd < 9)
			{
				//有可能是填充字符,去除掉
				for(int j = 7; j >= 8 - chEnd; --j)
				{
					if(endBuf[j] != chEnd)
						return 0;
				}

				memcpy(to + i, endBuf, 8 - chEnd);

				return i +  8 - chEnd;

			}
			else
			{
				return 0;
			}
		}


	}

	return 0;
}

int CHttpDes::des_cbc_pkcs7_encrypt(uchar* from, int nLength,  uchar * to, uchar key[],uchar iv[])
{
	//uchar buffer[8];
	int nSize = nLength % 8 ?(nLength + 7) / 8 * 8 : nLength + 8;
	if(to == NULL)
	{
		//计算长度
		return nSize;
	}
	else
	{
		deskey(key,EN0);
		uchar preEnc[8];
		memcpy(preEnc,iv,8);

		//加密块
		int i=0;
		for(; i < nSize; i+=8)
		{
			uchar*     ps = from + i;
			uchar*     pd = to + i;

			if(nSize - i > 8)
			{
				//XOR
				for(int j = 0; j < 8; ++j)
				{
					preEnc[j] ^= *(ps + j);
				}
			}
			else
			{
				//XOR
				for(int j = 0; j < nLength - i; ++j)
				{
					preEnc[j] ^= *(ps + j);
				}

				for(int j = nLength - i; j < 8; ++j)
				{
					preEnc[j] ^= nSize - nLength;
				}
			}

			des(preEnc,pd);
			//保存前一个输出
			memcpy(preEnc, pd,8);
		}
		return i;
	}
}



int CHttpDes::des_cbc_pkcs7_decrypt(uchar* from, int nLength,  uchar * to, uchar key[], uchar iv[])
{
	if(nLength % 8)
	{
		return 0;		//数据不正确
	}

	//XOR
	uchar preEnc[8],buffer[8];
	memcpy(preEnc,iv,8);

	deskey(key,DE1);

	int i = 0;
	for(; i<nLength; i+=8)
	{
		uchar* ps = from + i;
		uchar* pd = to + i;

		des(ps,buffer);

		//XOR
		for(int j = 0; j < 8; ++j)
		{
			buffer[j] ^= preEnc[j];
		}

		if(nLength - i > 8)
		{
			//保存前一个输出
			memcpy(preEnc, ps,8);
			memcpy(pd,buffer,sizeof(buffer));
		}
		else
		{
			//去除数据尾
			uchar chEnd = buffer[sizeof(buffer) - 1];
			if(chEnd > 0 && chEnd < 9)
			{
				//有可能是填充字符,去除掉
				for(int j = sizeof(buffer) - 1; j >= (int)(sizeof(buffer) - chEnd); --j)
				{
					if(buffer[j] != chEnd)
						return 0;
				}
				int nSize =nLength - chEnd;
				memcpy(pd, buffer, sizeof(buffer) - chEnd);
				return nLength - chEnd;
			}
			else
			{
				//数据格式不正确
				return 0;
			}
		}
	}
	return 0;
}
//把字节数组转换成字串
int CHttpDes::Byte2String(uchar* bytes, int nLength, char* pszout)
{
	if(!pszout)
	{
		return nLength * 2;
	}
	else
	{
		for (int i = 0; i < nLength; ++i)
		{
			//sb.AppendFormat("{0} ", b.ToString("X2"));
			sprintf(pszout + i * 2,"%2X ",bytes[i]);
		}

		*(pszout + nLength * 2) = '\0';
		return nLength * 2;
	}
}
void CHttpDes::cbcDesTest1()
{
//	char *szPrint = new char[1024];
	//asdfjkle
	uchar key[8] = {'a','s','d','f','j','k','l','e'};
	uchar iv[8] = {'a','s','d','f','j','k','l','e'};
	char *pSor = "123abc";
	uchar text[6] ={0};
	memcpy(text, pSor, 6);
	uchar *output = NULL;
	uchar text2[sizeof(text)];
	memset(&text2,0,sizeof(text2));

	int nLength = des_cbc_pkcs7_encrypt(text,6,NULL,key,iv);
	output = new uchar[nLength];
	memset(output,0,nLength);

	des_cbc_pkcs7_encrypt(text,6,output,key,iv);
	des_cbc_pkcs7_decrypt(output,nLength,text2,key,iv);
	//打印出来
	//Byte2String(text2,sizeof(text2),szPrint);
	printf("%s\n",text2);
	delete[] output;
	output = NULL;

}

int CHttpDes::GetEntryText(char *szSrc, int nLen, char* szOut ,int *retLen)
{
	int nRes = 0;			//返回的结果
	uchar *output = NULL;	//输出的数据
	char *szPrint = new char[1024];
	//固定密钥
	//asdfjkle
	uchar key[8] = {'a','s','d','f','j','k','l','e'};
	uchar iv[8] = {'a','s','d','f','j','k','l','e'};
    int nLength = 0;
	//复制数据
	uchar *text =  new uchar[nLen];
	if (!text)
	{
		nRes = 0;
	}
    else
    {
        memcpy(text, szSrc, nLen);
        nLength = des_cbc_pkcs7_encrypt(text,nLen,NULL,key,iv);
        if(nLength <= 0)
        {
            nRes = 0;

        }
        else{
            output = new uchar[nLength];
            memset(output,0,nLength);

            nRes = des_cbc_pkcs7_encrypt(text,nLen,output,key,iv);
        }
    }
	if (nRes > 0)//加密成功
	{
		szPrint = bin2hex((char*)output,nLength);
		memcpy(szOut,szPrint, strlen(szPrint)+1);
		if (szPrint)
		{
			delete [] szPrint;
			szPrint = NULL;
		}
        *retLen = nRes;
	}
	if (text)
	{
		delete []text;
		text = NULL;
	}
	return nRes;
}
int CHttpDes::GetEntryTextnew(char *szSrc, int nLen, char* szOut ,int *retLen)
{
    int nRes = 0;			//返回的结果
    uchar *output = NULL;	//输出的数据
    char *szPrint = new char[1024];
    //固定密钥
    //asdfjkle
    uchar key[8] = {'q','w','e','r','t','y','u','i'};
    uchar iv[8] = {'q','w','e','r','t','y','u','i'};
    int nLength = 0;
    //复制数据
    uchar *text =  new uchar[nLen];
    if (!text)
    {
        nRes = 0;
    }
    else
    {
        memcpy(text, szSrc, nLen);
        nLength = des_cbc_pkcs7_encrypt(text,nLen,NULL,key,iv);
        if(nLength <= 0)
        {
            nRes = 0;
            
        }
        else{
            output = new uchar[nLength];
            memset(output,0,nLength);
            
            nRes = des_cbc_pkcs7_encrypt(text,nLen,output,key,iv);
        }
    }
    if (nRes > 0)//加密成功
    {
        szPrint = bin2hex((char*)output,nLength);
        memcpy(szOut,szPrint, strlen(szPrint)+1);
        if (szPrint)
        {
            delete [] szPrint;
            szPrint = NULL;
        }
        *retLen = nRes;
    }
    if (text)
    {
        delete []text;
        text = NULL;
    }
    return nRes;
}
int CHttpDes::GetDecryptText(char *szSrc, int nLen, char* szOut )
{
	int nRes = 0;			//返回的结果
	uchar *output = NULL;	//输出的数据
	char *szPrint = new char[1024];
	//固定密钥
	//asdfjkle
	uchar key[8] = {'a','s','d','f','j','k','l','e'};
	uchar iv[8] = {'a','s','d','f','j','k','l','e'};
    int nLength = 0;
	//复制数据
	uchar *text =  new uchar[nLen];
	if (!text)
	{
		nRes = 0;
	}
    else
    {
        memcpy(text, szSrc, nLen);
        nLength = des_cbc_pkcs7_decrypt(text,nLen,NULL,key,iv);
        if(nLength <= 0)
        {
            nRes = 0;
        }
        else
        {
            output = new uchar[nLength];
            memset(output,0,nLength);

            nRes = des_cbc_pkcs7_decrypt(text,nLen,output,key,iv);
        }
    }
	if (nRes > 0)//加密成功
	{
		szPrint = bin2hex((char*)output,nLength);
		memcpy(szOut,szPrint, strlen(szPrint));
		if (szPrint)
		{
			delete [] szPrint;
			szPrint = NULL;
		}
	}
	if (text)
	{
		delete []text;
		text = NULL;
	}
	return nRes;
}

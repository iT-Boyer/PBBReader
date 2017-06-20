#include "utility.h"
#include <stdio.h>
#include <stdlib.h>

#include "SM3.h"

// 本机大端返回1，小端返回0
int checkCPUendian()
{

	union{

		unsigned long int i;

		unsigned char s[4];

	}c;

	c.i = 0x12345678;

	return (0x12 == c.s[0]);

}



// 模拟htonl函数，本机字节序转网络字节序

unsigned long int t_htonl(unsigned long int h)
{
	// 若本机为大端，与网络字节序同，直接返回
	// 若本机为小端，转换成大端再返回
	return checkCPUendian() ? h : BigLittleSwap32(h);
}
// 模拟ntohl函数，网络字节序转本机字节序
unsigned long int t_ntohl(unsigned long int n)
{

	// 若本机为大端，与网络字节序同，直接返回

	// 若本机为小端，网络数据转换成小端再返回

	return checkCPUendian() ? n : BigLittleSwap32(n);

}



// 模拟htons函数，本机字节序转网络字节序

unsigned short int t_htons(unsigned short int h)

{

	// 若本机为大端，与网络字节序同，直接返回

	// 若本机为小端，转换成大端再返回

	return checkCPUendian() ? h : BigLittleSwap16(h);

}



// 模拟ntohs函数，网络字节序转本机字节序

unsigned short int t_ntohs(unsigned short int n)
{

	// 若本机为大端，与网络字节序同，直接返回

	// 若本机为小端，网络数据转换成小端再返回

	return checkCPUendian() ? n : BigLittleSwap16(n);

}

char *bin2hex(char *bin,unsigned int bin_len)
{
	int pos = 0;
	int offset = 0;
	char *hex;

	hex = (char*)malloc(bin_len * 2 + 1);
	memset(hex,0,bin_len * 2 + 1);

	while(pos < bin_len)
	{
		offset += sprintf(hex + offset,"%02x",(unsigned char)bin[pos]);
		pos++;
	}

	return hex;
}

char *hex2bin(char *hex,unsigned int hex_len)
{
	int pos = 0;
	int offset = 0;

	long long_char;
	char *endptr;

	char temp_hex[3] = "\0\0";
	char *bin;
	bin = (char*)malloc(hex_len/2 + 1);
	memset(bin,0,hex_len/2 + 1);

	while(pos <= hex_len)
	{
		memcpy(temp_hex,hex+pos,2);
		long_char = strtol(temp_hex, &endptr, 16);
		if(long_char)
		{
			offset += sprintf(bin + offset, "%c", (unsigned char)long_char);
		}
		else
		{
			offset++;
		}
		pos += 2;
	}
	return bin;
}


int	INTToByte(int nValue,int outlen,unsigned char** outData)
{
	BYTE *p = (BYTE*)&nValue;
	int nData = (int)(p[0] << 24) + (int)(p[1] << 16) +
		(int)(p[2] << 8) + (int)p[3];
	BYTE* p1 =(BYTE*) malloc(4);
	BYTE* out = (BYTE*)malloc(outlen);
	memcpy(p1,&nData,4);
	memcpy(out,p1+2,outlen);
	
	if(p1)free(p1);
	*outData = out;
	return 1;
}
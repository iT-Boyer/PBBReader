#ifndef __UTILITY_H__
#define __UTILITY_H__
//#include <rpcndr.h>
#ifdef __cplusplus
extern "C" {
#endif

#ifndef uint16
#define uint16  unsigned short int
#endif

#ifndef uint32
#define uint32 unsigned long int
#endif


//typedef unsigned long int uint32;
typedef unsigned char BYTE;

// 短整型大小端互换
#define BigLittleSwap16(A) ((((uint16)(A) & 0xff00) >> 8) | (((uint16)(A) & 0x00ff) << 8))

// 长整型大小端互换
#define BigLittleSwap32(A) ((((uint32)(A) & 0xff000000) >> 24) | \
		(((uint32)(A) & 0x00ff0000) >> 8) | \
		(((uint32)(A) & 0x0000ff00) << 8) | \
		(((uint32)(A) & 0x000000ff) << 24))

// 本机大端返回1，小端返回0
int checkCPUendian();

// 模拟htonl函数，本机字节序转网络字节序

unsigned long int t_htonl(unsigned long int h);

// 模拟ntohl函数，网络字节序转本机字节序
unsigned long int t_ntohl(unsigned long int n);

// 模拟htons函数，本机字节序转网络字节序

unsigned short int t_htons(unsigned short int h);

// 模拟ntohs函数，网络字节序转本机字节序

unsigned short int t_ntohs(unsigned short int n);


//typedef unsigned long DWORD;


//DWORD ToLittleEndian(DWORD dwBigEndian);
char *bin2hex(char *bin,unsigned int bin_len);
char *hex2bin(char *hex,unsigned int hex_len);

/*
* @brief 整数到字节串的转换函数
* @param[in] nValue		输入的整数乘以8
* @param[in] outlen		要输出字节串的长度
* @param[out] outData	输出的字节串
* @return 返回操作成功与否
* @retval 1 操作成功
* @retval 0 操作失败
*/
int	INTToByte(int nValue,int outlen,unsigned char** outData);


#ifdef __cplusplus
}
#endif
#endif
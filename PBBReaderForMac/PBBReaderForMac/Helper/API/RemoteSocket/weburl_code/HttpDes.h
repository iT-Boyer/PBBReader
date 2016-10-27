/**
 * @file HttpDes.h
 * @brief 用于跟http交互，别的地方没有用到，为了与公共模块兼容
 *		  添加该模块
 * @author
 * @date
 * @version
*/
#ifndef __HTTPDES_H__
#define __HTTPDES_H__

#include "Des.h"
typedef unsigned char uchar;

class CHttpDes
{
public:
	CHttpDes();
	~CHttpDes();

public:
	/*
	 * @brief 因为只用到和pyc网站交换，密钥是固定的，所以添加这个函数
	 * @param[in] szSrc		要加密的数据
	 * @param[in] nLen		要加密数据的长度
	 * @param[out] szOut	加密后的数据
	 * @return 
	 * @retval 1 操作成功
	 * @retval 0 操作失败
	 */
	int GetEntryText(char *szSrc, int nLen, char* szOut,int *retLen);
public:
    /*
     * @brief 因为只用到和pyc网站交换，密钥是固定的，所以添加这个函数
     * @param[in] szSrc		要加密的数据
     * @param[in] nLen		要加密数据的长度
     * @param[out] szOut	加密后的数据
     * @return
     * @retval 1 操作成功
     * @retval 0 操作失败
     */
    int GetEntryTextnew(char *szSrc, int nLen, char* szOut,int *retLen);
public:
	/*
	 * @brief 因为只用到和pyc网站交换，密钥是固定的，所以添加这个函数
	 * @param[in] szSrc		要解密的数据
	 * @param[in] nLen		要解密数据的长度
	 * @param[out] szOut	解密后的数据
	 * @return 
	 * @retval 1 操作成功
	 * @retval 0 操作失败
	 */
	int GetDecryptText(char *szSrc, int nLen, char* szOut);
public:
	/*
	 * @brief 功能：用mode = ecb , padding = pkcs7 来加密
	 *				如果to == NULL, 则返回加密后数据的长度
	 * @param[in] from		要加密的数据
	 * @param[in] nLength	要加密数据的长度
	 * @param[out] to		加密后的数据
	 * @param[in]  key[]	加密用到的key
	 */
	int des_ecb_pkcs7_encrypt(uchar* from, int nLength,  uchar * to, uchar key[]);

	/*
	 * @brief 功能：用mode = ecb , padding = pkcs7 来解密
	 *
	 * @param[in] from		要解密的数据
	 * @param[in] nLength	要解密数据的长度
	 * @param[out] to		解密后的数据
	 * @param[in]  key[]	解密用到的key
	 */
	int des_ecb_pkcs7_decrypt(uchar* from, int nLength,  uchar * to, uchar key[]);

	/*
	 * @brief	用mode = cbc , padding = pkcs7 来加密数据
	 *			如果to == NULL, 则返回加密后数据的长度
	 * @param[in]  from		要加密的数据
	 * @param[in]  nLength	要加密数据的长度
	 * @param[out] to		加密后的数据
	 * @param[in]  key[]	加密用到的key
	 * @param[in]  iv[]		加密数据的key向量
	 */
	int des_cbc_pkcs7_encrypt(uchar* from, int nLength,  uchar * to, uchar key[],uchar iv[]);

	/*
	 * @brief	用mode = cbc , padding = pkcs7 来解密数据
	 *			如果to == NULL, 则返回加密后数据的长度
	 * @param[in]  from		要解密的数据
	 * @param[in]  nLength	要解密数据的长度
	 * @param[out] to		解密后的数据
	 * @param[in]  key[]	解密用到的key
	 * @param[in]  iv[]		解密用到的key向量
	 */
	int des_cbc_pkcs7_decrypt(uchar* from, int nLength,  uchar * to, uchar key[], uchar iv[]);


	/*
	 * @brief	把字节数组转换成字串
	 * @param[in]  bytes	要转换的数据
	 * @param[in]  nLength	要转换的数据长度
	 * @param[out] pszout	转换后的数据
	 */
	int Byte2String(uchar* bytes, int nLength, char* pszout);
	/*
	 * @brief 测试程序
	 */
	void cbcDesTest1();
};

#endif
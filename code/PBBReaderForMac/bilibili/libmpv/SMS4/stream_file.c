/*
 * Original authors: Albeu, probably Arpi
 *
 * This file is part of mpv.
 *
 * mpv is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * mpv is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with mpv.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "config.h"

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#ifndef __MINGW32__
#include <poll.h>
#endif

#include "osdep/io.h"

#include "common/common.h"
#include "common/msg.h"
#include "stream.h"
#include "options/m_option.h"
#include "options/path.h"

#if HAVE_BSD_FSTATFS
#include <sys/param.h>
#include <sys/mount.h>
#endif

#if HAVE_LINUX_FSTATFS
#include <sys/vfs.h>
#endif

#ifdef _WIN32
#include <windows.h>
#include <winternl.h>
#include <io.h>

#ifndef FILE_REMOTE_DEVICE
#define FILE_REMOTE_DEVICE (0x10)
#endif
#endif

struct priv {
    int fd;
    bool close;
    bool regular;
};


//-------------------------------------
//解密算法
//-------------------------------------


/**
 * @file SMS4.cpp
 * @brief SMS4À„∑® µœ÷Œƒº˛
 * @author
 * @date
 * @version
 */

/* define SMS4DBG flag for debug these code */


/* reserved for saving interface */

#include "SMS4.h"
#include <string.h>

/*=============================================================================
 ** private function:
 **   look up in SboxTable and get the related value.
 ** args:    [in] inch: 0x00~0xFF (8 bits unsigned value).
 **============================================================================*/
 uint8 SMS4Sbox(uint8 inch)
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
 uint32 SMS4Lt(uint32 a)
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
 uint32 SMS4CalciRK(uint32 a)
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
 void SMS4CalcRK(uint32 ulflag)
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
 uint32 SMS4T(uint32 a)
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
 uint32 SMS4F(uint32 x0, uint32 x1, uint32 x2, uint32 x3, uint32 rk)
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
    if (ulkey != NULL)
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
    uint32 *pRet = NULL;
    uint32 i = 0;
    
    uint32 ulbuf[36];
    
    uint32 ulCnter = 0;
    uint32 ulTotal = (lgsrc >> 4);
    
    
    if(psrc != NULL)
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
/*
 uint32 *SMS4Decrypt(uint32 *psrc, uint32 lgsrc, uint32 derk[])
 {
	uint32 *pRet = NULL;
	uint32 i = 0;
 
	if(psrc != NULL)
	{
 pRet = psrc;
 
 /* the same arithmetic, different encryption key sequence. */
/*		SMS4EncryptOld(psrc, lgsrc, derk);
	}
 
	return pRet;
 }
 */
uint32 *SMS4Encrypt(uint32 *psrc, uint32 lgsrc,uint32 flag)
{
    uint32 *pRet = NULL;
    uint32 i = 0;
    
    uint32 ulbuf[36];
    
    uint32 ulCnter = 0;
    uint32 ulTotal = (lgsrc >> 4);
    
    
    if(psrc != NULL)
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
    uint32 *pRet = NULL;
    uint32 i = 0;
    
    if(psrc != NULL)
    {
        pRet = psrc;
        
        /* the same arithmetic, different encryption key sequence. */
        SMS4Encrypt(psrc, lgsrc, 0);
    }
    
    return pRet;
}


#include "pbb_key.h"

#define KEY_LEN 16
#define format16_right(x) ( (x)%16 !=0 ? (x)+16-(x)%16 : (x) )
#define format16_left(x) ( (x)%16 !=0 ? (x)-(x)%16 : (x) )
#define min(x,y) ( (x)>(y) ? (y):(x) )

//2.mp4.pbb
//unsigned char key_r[KEY_LEN+1] = {-1,54,-34,48,-51,-21,-97,-116,22,55,-116,-110,-37,-96,98,29};
//long long code_len_r = 1486272;
////long long code_len_r = 0;
//long long offset_r = 2097154;   //第二次加密，文件头部的偏移量
//long long file_len_r = 1486261;

//邓紫棋
//unsigned char key_r[KEY_LEN+1] = {18,106,-35,-58,52,-99,-75,35,-85,-49,-99,53,84,120,-10,106};
//long long code_len_r = 54476192;
////long long code_len_r = 0;
//long long offset_r = 2097155;   //第二次加密，文件头部的偏移量
//long long file_len_r = 54476185;

////1.mp4.pbb
//unsigned char key_r[KEY_LEN+1] = {45,35,92,-47,-58,-36,-20,49,-75,32,39,-86,15,7,-40,-88};
//long long code_len_r = 2030336;
////long long code_len_r = 0;
//long long offset_r = 0;   //第二次加密，文件头部的偏移量
//long long file_len_r = 2030327;

//usb的文件
//unsigned char key_r[KEY_LEN+1] = {118,-86,-54,37,15,-51,-49,10,-55,-87,95,44,39,-126,61,-104};
//long long code_len_r = 136252912;
////long long code_len_r = 0;
//long long offset_r = 0;   //第二次加密，文件头部的偏移量
//long long file_len_r = 136252898;

//燕测试文件
//unsigned char key_r[KEY_LEN+1] = {-29,-69,-24,-80,29,127,-113,43,-96,84,44,59,-7,-20,-65,-76};
//long long code_len_r = 2408944;
////long long code_len_r = 0;
//long long offset_r = 0;   //第二次加密，文件头部的偏移量
//long long file_len_r = 2408936;
//const unsigned char *path = "/storage/emulated/0/0.log";

unsigned char key_r[KEY_LEN+1];
long long code_len_r = 0;
//long long code_len_r = 0;
long long offset_r = 0;   //第二次加密，文件头部的偏移量
long long file_len_r = 0;


long long get_offset()
{
    return offset_r;
}

/*
 * 设置密钥和加密长度
 */
void set_key_info(unsigned char* key, long long code_len,long long file_len,long long offset) {
    //    unlink(path);
    if (key) {
        release_key(); //设置前线释放key_r和code_len_r以免影响后续判断
        memcpy(key_r,key,KEY_LEN);
        
        code_len_r = format16_right(code_len); //有的时候加密长度不是16的倍数
        offset_r = offset;
        file_len_r = file_len;
        
        //        FILE* file = fopen(path,"a+");
        //        fprintf(file,"set_key_info offset: %d  \n",offset);
        //        fclose(file);
        
    } else {
        release_key();
    }
}

void release_key() {
    if (key_r) {
        memset(key_r, 0, KEY_LEN);
    }
    code_len_r = 0;
    offset_r = 0;
    file_len_r = 0;
}

 char buf_tmp[2<<20];
//char code_bu[16];
//    char test[] = {"abcdefghijklmnopqrstuvwxyz"};
//From Me
static int file_read(int fd,  char *buf, int size) {
    int r;
    
    //    //我们的key中间可能含有"\0"结束符，所以不能以key的长度判断
    //    //if(strlen(key)==KEY_LEN&&code_len_r>0)
    //    if (code_len_r > 0) {
    //        long long cur_pos = lseek(fd, 0, SEEK_CUR); //SEEK_CUR可以确定当前位置，还有一个tell函数也可以，但linux不支持
    //
    //        //二代加密算法导致的偏移量
    //        if (cur_pos<offset_r) {
    //            lseek(fd,offset_r,SEEK_SET);
    //            cur_pos = offset_r;
    //
    ////            FILE* file = fopen(path,"a+");
    ////            fprintf(file,"Read调整偏移量 offset: %d \n",offset_r);
    ////            fclose(file);
    //        }
    //
    //        // 有时候cur_pos是-1（加入long long 之后应该不会了）
    //        if (cur_pos > code_len_r + offset_r || cur_pos < offset_r || size <= 0) {
    //            r = read(fd, buf, size);
    //            return (-1 == r) ? AVERROR(errno) : r;
    //        }
    //
    //        /*二代算法V2*/
    //        /*
    //         * 我们的加密算法要求数据其实位置是16的倍数，加密长度是16的倍数。即左右节点都得是16的倍数
    //         * 此处要保证左右节点包含buf的大小
    //         */
    //
    //        //        FILE* file1 = fopen(path,"a+");
    //        //        fprintf(file1,"Read之前 cur pos:%d   offset:%d  减去： %d \n", cur_pos, offset_r,(cur_pos - offset_r)%16);
    //        //        fclose(file1);
    //
    //        /* 第一步：读取加密数据（code_left+code_size），包含播放器需要的数据（cur_pos+size） */
    //        const int code_offset = (cur_pos - offset_r) % 16;
    //        const long long code_left = cur_pos - code_offset; //左边界，包含播放器所需数据
    //        const int code_size = format16_right(size + code_offset);    //读取量，大于播放器需要的数目
    //
    ////        FILE* file = fopen(path,"a+");
    ////        fprintf(file,"Read cur pos:%d   offset_r: %d  file_en %d \n", cur_pos,offset_r,file_len_r);
    ////        fclose(file);
    //
    //        unsigned char* code_buf = (unsigned char*) malloc(code_size);
    //
    //        lseek(fd, code_left, SEEK_SET); //移动，准备读密文
    //        int real_read = read(fd, code_buf, code_size);
    //
    //        int code_len = 0;   //读取数据的密文长度
    //        if (code_len_r + offset_r >= code_left + real_read) {
    //            code_len = real_read; //读到的全是密文
    //        } else {
    //            code_len = code_len_r + offset_r - code_left; //一部分是密文，那么code_len就等于这“一部分”的大小
    //        }
    //
    //        SMS4SetKey((uint32*) key_r, 1);
    //        SMS4Decrypt((uint32*) code_buf, (int)format16_right(code_len)); //注意，再确认下，length是16倍数
    //
    //        const int valid_read = FFMIN(size,real_read-code_offset);   //供给播放器的数据大小
    //        memcpy(buf, code_buf + code_offset, valid_read);
    //        lseek(fd, cur_pos + valid_read, SEEK_SET); //这个是必须的。还原到和直接调用read(fd, buf, size)一样的效果
    //        free(code_buf);
    //        r = valid_read;
    //    } else {
    //        r = read(c->fd, buf, size);
    //    }
    //
    //    return (-1 == r) ? AVERROR(errno) : r;
    
    //    //我们的key中间可能含有"\0"结束符，所以不能以key的长度判断
    //    //if(strlen(key)==KEY_LEN&&code_len_r>0)

//     long long cur_pos_1 = lseek(fd, 0, SEEK_CUR);
//     printf("当前位置：：： %d   要求的大小：：：%d\n",cur_pos_1,size);
    if (code_len_r > 0) {
        long long cur_pos = lseek(fd, 0, SEEK_CUR); //SEEK_CUR可以确定当前位置，还有一个tell函数也可以，但linux不支持
//        printf("1   %d  %d\n",cur_pos,size);
        if (cur_pos<offset_r) {
            lseek(fd,offset_r,SEEK_SET);
            cur_pos = offset_r;
            
            //                    FILE* file = fopen(path,"a+");
            //                    fprintf(file,"Read调整偏移量 offset: %d \n",offset_r);
            //                    fclose(file);
            
//            printf("2\n");
        }
        
        // 有时候cur_pos是-1（加入long long 之后应该不会了）
        if (cur_pos > code_len_r + offset_r || cur_pos < 0) {
            r = read(fd, buf, size);
            return r;
        }
        
//        printf("3\n");
        
        /*
         * 我们的加密算法要求数据其实位置是16的倍数，加密长度是16的倍数。即左右节点都得是16的倍数
         * 此处要保证左右节点包含buf的大小
         */
        //        long long left_pos = format16_left(cur_pos);
        //        long long right_pos = format16_right(cur_pos + size);
        long long left_pos = cur_pos - (cur_pos - offset_r)%16;
        long long right_pos = format16_right(cur_pos + size - offset_r) + offset_r;
        
        int size_tmp = right_pos - left_pos;
        
//        printf("需要缓冲的字节大小：%d",size_tmp);
        
//        printf("left:%d,right:%d,size:%d\n",left_pos,right_pos,size_tmp);
        
        if (left_pos!=cur_pos) {
        lseek(fd, left_pos, SEEK_SET);
        }
        
        int read_tmp = read(fd, buf_tmp, size_tmp); //注意：read_tmp<=size_tmp，后面的判断就是因为这个原因
        
//        printf("4\n");
        
        const long long cur_pos_now = left_pos + read_tmp; //现在流所处的实际位置，要区别cur_pos
        int code_len = 0;
        if (code_len_r + offset_r > cur_pos_now) {
            code_len = read_tmp; //读到的全是密文
//            printf("全是密文 read_tmp::%d\n",read_tmp);
        } else {
            code_len = code_len_r + offset_r - left_pos; //一部分是密文，那么code_len就等于这“一部分”的大小
//            printf("部分密文\n");
        }
        
//        printf("5\n");
        
//        memcpy(code_bu,buf_tmp,16);
//        SMS4SetKey((uint32 *) key_r, 1);
//        printf("加密前：\n");
//        for (int i=0; i<16; i++) {
//            printf("%d ",code_bu[i]);
//        }
//        printf("\n");
//        SMS4Encrypt((uint32 *)code_bu,16,16);
//        printf("加密后：\n");
//        for (int i=0; i<16; i++) {
//            printf("%d ",code_bu[i]);
//        }
//        printf("\n");
//    
//        SMS4SetKey((uint32 *) key_r, 1);
//        SMS4Decrypt((uint32 *) code_bu, 16);
//        printf("解密后：\n");
//        for (int i=0; i<16; i++) {
//            printf("%d ",code_bu[i]);
//        }
//        printf("\n");
        
        SMS4SetKey((uint32 *) key_r, 1);
        SMS4Decrypt((uint32 *) buf_tmp, code_len);

        
//        printf("加密前：  %s\n",test);
//        
//        SMS4Encrypt((uint32 *)test,16,1);
//        
//        printf("加密后：  %s\n",test);
//        
//        SMS4Decrypt((uint32*) test, 16);
//        
//        printf("解密后：  %s\n",test);
//        
//        
//        printf("\n6\n");
        
        const int left_offset = cur_pos - left_pos;
        //valid_read即播放器实际需要的数据（<=size)
        const int valid_read =
        read_tmp - left_offset < size ? read_tmp - left_offset : size; //去掉因加密规则而format的那些数据
        
//        printf("7   valid_read：：：%d\n",valid_read);
        
        memcpy(buf, buf_tmp + left_offset, valid_read);
//        for (int i=left_offset; i<left_offset+valid_read; i++) {
//            buf[i-left_offset] = buf_tmp[i];
//        }
        
//        printf("71\n");
//        free(buf_tmp);
        
//        printf("72\n");
        lseek(fd, cur_pos + valid_read, SEEK_SET); //这个是必须的。还原到和直接调用read(fd, buf, size)一样的效果
//        
//        printf("8\n");
        
        r = valid_read;
        return  r;
        
    } else {
        r = read(fd, buf, size);
        return r;
    }
    
}

static int fill_buffer(stream_t *s, char *buffer, int max_len)
{
    struct priv *p = s->priv;
#ifndef __MINGW32__
    if (!p->regular) {
        int c = s->cancel ? mp_cancel_get_fd(s->cancel) : -1;
        struct pollfd fds[2] = {
            {.fd = p->fd, .events = POLLIN},
            {.fd = c, .events = POLLIN},
        };
        poll(fds, c >= 0 ? 2 : 1, -1);
        if (fds[1].revents & POLLIN)
            return -1;
    }
#endif
//        int r = read(p->fd, buffer, max_len);
    int r = file_read(p->fd,buffer,max_len);
    return (r <= 0) ? -1 : r;
}



static int write_buffer(stream_t *s, char *buffer, int len)
{
    struct priv *p = s->priv;
    int r;
    int wr = 0;
    while (wr < len) {
        r = write(p->fd, buffer, len);
        if (r <= 0)
            return -1;
        wr += r;
        buffer += r;
    }
    return len;
}

static int seek(stream_t *s, int64_t newpos)
{
    struct priv *p = s->priv;
    return lseek(p->fd, newpos+offset_r, SEEK_SET) != (off_t)-1;
}

static int control(stream_t *s, int cmd, void *arg)
{
    struct priv *p = s->priv;
    switch (cmd) {
    case STREAM_CTRL_GET_SIZE: {
        off_t size = lseek(p->fd, 0, SEEK_END);
        lseek(p->fd, s->pos+offset_r, SEEK_SET);
        if (size != (off_t)-1) {
            *(int64_t *)arg = size;
            return 1;
        }
        break;
    }
    }
    return STREAM_UNSUPPORTED;
}

static void s_close(stream_t *s)
{
    struct priv *p = s->priv;
    if (p->close && p->fd >= 0)
        close(p->fd);
}

// If url is a file:// URL, return the local filename, otherwise return NULL.
char *mp_file_url_to_filename(void *talloc_ctx, bstr url)
{
    bstr proto = mp_split_proto(url, &url);
    if (bstrcasecmp0(proto, "file") != 0)
        return NULL;
    char *filename = bstrto0(talloc_ctx, url);
    mp_url_unescape_inplace(filename);
#if HAVE_DOS_PATHS
    // extract '/' from '/x:/path'
    if (filename[0] == '/' && filename[1] && filename[2] == ':')
        memmove(filename, filename + 1, strlen(filename)); // including \0
#endif
    return filename;
}

// Return talloc_strdup's filesystem path if local, otherwise NULL.
// Unlike mp_file_url_to_filename(), doesn't return NULL if already local.
char *mp_file_get_path(void *talloc_ctx, bstr url)
{
    if (mp_split_proto(url, &(bstr){0}).len) {
        return mp_file_url_to_filename(talloc_ctx, url);
    } else {
        return bstrto0(talloc_ctx, url);
    }
}

#if HAVE_BSD_FSTATFS
static bool check_stream_network(int fd)
{
    struct statfs fs;
    const char *stypes[] = { "afpfs", "nfs", "smbfs", "webdav", NULL };
    if (fstatfs(fd, &fs) == 0)
        for (int i=0; stypes[i]; i++)
            if (strcmp(stypes[i], fs.f_fstypename) == 0)
                return true;
    return false;

}
#elif HAVE_LINUX_FSTATFS
static bool check_stream_network(int fd)
{
    struct statfs fs;
    const uint32_t stypes[] = {
        0x5346414F  /*AFS*/,    0x61756673  /*AUFS*/,   0x00C36400  /*CEPH*/,
        0xFF534D42  /*CIFS*/,   0x73757245  /*CODA*/,   0x19830326  /*FHGFS*/,
        0x65735546  /*FUSEBLK*/,0x65735543  /*FUSECTL*/,0x1161970   /*GFS*/,
        0x47504653  /*GPFS*/,   0x6B414653  /*KAFS*/,   0x0BD00BD0  /*LUSTRE*/,
        0x564C      /*NCP*/,    0x6969      /*NFS*/,    0x6E667364  /*NFSD*/,
        0xAAD7AAEA  /*PANFS*/,  0x50495045  /*PIPEFS*/, 0x517B      /*SMB*/,
        0xBEEFDEAD  /*SNFS*/,   0xBACBACBC  /*VMHGFS*/, 0x7461636f  /*OCFS2*/,
        0
    };
    if (fstatfs(fd, &fs) == 0) {
        for (int i=0; stypes[i]; i++) {
            if (stypes[i] == fs.f_type)
                return true;
        }
    }
    return false;

}
#elif defined(_WIN32)
static bool check_stream_network(int fd)
{
    NTSTATUS (NTAPI *pNtQueryVolumeInformationFile)(HANDLE,
        PIO_STATUS_BLOCK, PVOID, ULONG, FS_INFORMATION_CLASS) = NULL;

    // NtQueryVolumeInformationFile is an internal Windows function. It has
    // been present since Windows XP, however this code should fail gracefully
    // if it's removed from a future version of Windows.
    HMODULE ntdll = GetModuleHandleW(L"ntdll.dll");
    pNtQueryVolumeInformationFile = (NTSTATUS (NTAPI*)(HANDLE,
        PIO_STATUS_BLOCK, PVOID, ULONG, FS_INFORMATION_CLASS))
        GetProcAddress(ntdll, "NtQueryVolumeInformationFile");

    if (!pNtQueryVolumeInformationFile)
        return false;

    HANDLE h = (HANDLE)_get_osfhandle(fd);
    if (h == INVALID_HANDLE_VALUE)
        return false;

    FILE_FS_DEVICE_INFORMATION info = { 0 };
    IO_STATUS_BLOCK io;
    NTSTATUS status = pNtQueryVolumeInformationFile(h, &io, &info,
        sizeof(info), FileFsDeviceInformation);
    if (!NT_SUCCESS(status))
        return false;

    return info.DeviceType == FILE_DEVICE_NETWORK_FILE_SYSTEM ||
           (info.Characteristics & FILE_REMOTE_DEVICE);
}
#else
static bool check_stream_network(int fd)
{
    return false;
}
#endif

static int open_f(stream_t *stream)
{
    struct priv *p = talloc_ptrtype(stream, p);
    *p = (struct priv) {
        .fd = -1
    };
    stream->priv = p;
    stream->type = STREAMTYPE_FILE;

    bool write = stream->mode == STREAM_WRITE;
    int m = O_CLOEXEC | (write ? O_RDWR | O_CREAT | O_TRUNC : O_RDONLY);

    char *filename = mp_file_url_to_filename(stream, bstr0(stream->url));
    if (filename) {
        stream->path = filename;
    } else {
        filename = stream->path;
    }

    if (strncmp(stream->url, "fd://", 5) == 0) {
        char *end = NULL;
        p->fd = strtol(stream->url + 5, &end, 0);
        if (!end || end == stream->url + 5 || end[0]) {
            MP_ERR(stream, "Invalid FD: %s\n", stream->url);
            return STREAM_ERROR;
        }
        p->close = false;
    } else if (!strcmp(filename, "-")) {
        if (!write) {
            MP_INFO(stream, "Reading from stdin...\n");
            p->fd = 0;
        } else {
            MP_INFO(stream, "Writing to stdout...\n");
            p->fd = 1;
        }
        p->close = false;
    } else {
        mode_t openmode = S_IRUSR | S_IWUSR;
#ifndef __MINGW32__
        openmode |= S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH;
        if (!write)
            m |= O_NONBLOCK;
#endif
        p->fd = open(filename, m | O_BINARY, openmode);
        if (p->fd < 0) {
            MP_ERR(stream, "Cannot open file '%s': %s\n",
                   filename, mp_strerror(errno));
            return STREAM_ERROR;
        }
        struct stat st;
        if (fstat(p->fd, &st) == 0) {
            if (S_ISDIR(st.st_mode)) {
                stream->type = STREAMTYPE_DIR;
                stream->allow_caching = false;
                MP_INFO(stream, "This is a directory - adding to playlist.\n");
            }
#ifndef __MINGW32__
            if (S_ISREG(st.st_mode)) {
                p->regular = true;
                // O_NONBLOCK has weird semantics on file locks; remove it.
                int val = fcntl(p->fd, F_GETFL) & ~(unsigned)O_NONBLOCK;
                fcntl(p->fd, F_SETFL, val);
            }
#endif
        }
        p->close = true;
    }

#ifdef __MINGW32__
    setmode(p->fd, O_BINARY);
#endif

    off_t len = lseek(p->fd, 0, SEEK_END);
    lseek(p->fd, 0+offset_r, SEEK_SET);
    if (len != (off_t)-1) {
        stream->seek = seek;
        stream->seekable = true;
    }

    stream->fast_skip = true;
    stream->fill_buffer = fill_buffer;
    stream->write_buffer = write_buffer;
    stream->control = control;
    stream->read_chunk = 64 * 1024;
    stream->close = s_close;

    if (check_stream_network(p->fd))
        stream->streaming = true;

    return STREAM_OK;
}

const stream_info_t stream_info_file = {
    .name = "file",
    .open = open_f,
    .protocols = (const char*const[]){ "file", "", "fd", NULL },
    .can_write = true,
    .is_safe = true,
};

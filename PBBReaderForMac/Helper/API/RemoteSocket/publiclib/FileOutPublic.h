//
//  FileOutPublic.h
//  PycSocket
//
//  Created by Fairy on 13-11-7.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#ifndef PycSocket_FileOutPublic_h
#define PycSocket_FileOutPublic_h


#define TYPE_FILE_OUT                   400 //制作自由传播文件
#define TYEP_FILE_SAVE_HASH_ENCRYPT     401 //制作完成后，上传hash、密钥
#define TYPE_FILE_OPEN                  402 //打开文件
#define TYPE_FILE_REFRESH               416 //带有是否允许查看限制条件
#define TYPE_FILE_INFO                  413 //单个文件刷新
#define TYPE_FILE_CHANGE_READ_CONDITION 404 //修改自由传播条件
#define TYPE_FILE_CHANGE_FILE_CONTROLL  415 //禁止阅读或取消禁止
#define TYPE_FILE_OUT_SALER_APPLY       407 //制作手动激活文件
#define TYPE_APPLY                      408 //申请激活
#define TYPE_SEE_ACTIVE_OVERLIST        209 //查看激活后不能读的记录
#define TYPE_SEE_FILE_OVER              412 //文件阅读结束后，通知服务器
#define TYPE_REAPPLY                    409  // 重新申请激活
#define TYPE_FILE_APPLYINFO             403  // 查看提交申请信息
#define TYPE_FILE_CLIENT                405  // 离线验证
#define TYPE_FILE_VERIFICATIONCODE      420  // 申取验证码
#define NewPycUerRemoteOperateTypeBindPhone  321
#define NewPycUerRemoteOperateTypeGetConfirm  322


#define SOCKET_FILE_OUT_SUCCESS         1
#define SOCKET_FILE_OUT_FAILED          0

#define FILE_READ_CONDITION_CANOPEN     1
#define FILE_READ_CONDITION_CANNOTOPEN  0

#define MAC_LEN 17
#define VERSION_LEN 31
#define PHONE_LEN 20
#define EMAIL_LEN 50
#define NOT_USE_LEN_RECEIVE 28
#define NOT_USE_LEN_SEND 7

#define SHOW_INFO_LEN 100

#define USERNAME_LEN 50
#define TIME_LEN 10
#define MAC_LEN 17
#define FILENAME_LEN 260
#define FILENAME_LEN_OUTLINE 263
#define HASH_LEN 32
#define ENCRYPKEY_LEN 16
#define ENCRYPKEY_DU_LEN 256
#define NOT_USE_LEN 12
#define NICK_LEN    50
#define REMARK_LEN 200

#define LONGTIME_LEN 19

#define NOT_USE_LEN_LEN 50
#define FIRST_SEE_TIME_LEN 19
#define HARDNO_LEN 50
#define SYSINFO_LEN 30
#define QQ_LEN 20
#define ORDERNO_LEN 29
#define FIELD_LEN 24
#define VERSION 2030100  //2.1.2-9；2.3.1-2030100

#define NOT_USE_LEN_NEW_FILE 124
#define SESSION_KEY_LEN 256


#define ERR_TIME_BECAUSE -2
#define ERR_NUM_BECAUSE -1
#define ERR_AUTHOR_BECAUSE -3
#define ERR_AUTHOR_BECAUSE_AND_OTHER -4
#define ERR_SOCKET 0
#define ERR_OK 1
#define ERR_OK_NOTCHECKED 0
#define ERR_NOUPDATE 3

#define DEFAULT_BUFFER	2048

#define PORT_FILE   5005
#define PORT_OUTFILE 5006
#define SECRET_KEY_LEN  16
//#define HASH_STRUCT_LEN 32
#define HASH_FILE_SIZE_TODO (1024*1024*2)

#define FILE_LIST_PATH @"fileTypeDic.txt"

#define FILE_TYPE_MOVIE 1
#define FILE_TYPE_PIC   2
#define FILE_TYPE_PDF   3
#define FILE_TYPE_UNKOWN    4
#define MESSAGE_ID_LEN  24

#define SELFDEFINE_LEN 24
#define SHOW_INFO_LEN 100
#define SERIESNAME_LEN 100

#define LEN_MOVIE   (10 * 1024 *1024)
#define LEN_PIC     (4096)
#define LEN_PDF     (4096)
#define LEN_UNKOWN  (4096)

#define WRITE_FILE_INFO_TO_FILE 1

#define ARC4RANDOM_MAX      0x100000000   //随机数最大值
//!todo add nickname
typedef struct _STRUCT_DATA_
{
    int fileOpenNum;           //文件打开次数限制
    int fileOpenedNum;          //已经打开的次数
    int bCanPrint;              //是否允许打印   0
    int iCanOpen;           //是否允许脱机打开 0bNotLinkOpen
    int ID;                     //数据库纪录的ID
    int             iOpenTimeLong;
    int             appType;
    int             random;
    int             version;
    int             dayNum;
    int             yearNum;
    int             noticeNum;
    int             dayRemain;
    int             yearRemain;
    int             ooid;
    int             bindNum;
    int             activeNum;
    int             otherset;
    char logName[USERNAME_LEN +1];       //外发制作者的登陆名
    char fileoutName[FILENAME_LEN+1];   //被制作的文件名
    char startTime[TIME_LEN+1];         //有效开始日期 xxxx-xx-xx
    char endTime[TIME_LEN+1];           //有效结束日期
    char macAddr[MAC_LEN+1];            //本机网卡mac 地址
    char nick[NICK_LEN+1];//nick name
	char remark[REMARK_LEN + 1];//备注
    char versionStr[VERSION_LEN + 1];
    char email[EMAIL_LEN + 1];
    char QQ[QQ_LEN + 1];
    char phone[PHONE_LEN + 1];
    char hardno[HARDNO_LEN + 1];
    char sysinfo[SYSINFO_LEN + 1];
    unsigned char HashValue[HASH_LEN];
    unsigned char EncodeKey[ENCRYPKEY_LEN];
    unsigned char SessionKey[ENCRYPKEY_LEN];
    char firstSeeTime[FIRST_SEE_TIME_LEN+1];
    char outTime[FIRST_SEE_TIME_LEN+1];
    char orderno[ORDERNO_LEN+1];
    char field1[FIELD_LEN+1];
    char field2[FIELD_LEN+1];
    //unsigned char notUsed[NOT_USE_LEN_LEN];
    
}STRUCTDATA;

typedef struct _SEND_DATA_
{
    short       type;       //发送的信息 类型
    
    short       suc;
    int       pos1;
    int       pos2;
    
    STRUCTDATA  userData;
}SENDDATA;

typedef struct _STRUCT_DATA_NEW_NEW
{
    int			fileOpenNum;		//!< 文件打开次数
	int			fileOpenedNum;		//!< 文件已经被打开次数|离线验证时传给服务器
	int			bCanPrint;			//!< 文件是否允许打印
	int			iCanOpen;			//!< 制作者是否允许打开
	int			ID;					//数据库记录ID  |  查看时返回自定义字段是否保密输入 1：字段1需保密 2：字段2需保密 3：两个都需保密
	int			iOpenTimeLong;		//打开时长
	int			appType;				//客户端类别：;28;29;30
	int			random;				//传输随机因子
	int			version;			//客户端版本，用来比对是否过期 | 能查看时，返回查看记录ID，结束查看时调用结束业务，传给服务器
	int			dayNum;				//限制天数，规则：无限制，天数值；年数值+10000
	int			yearNum;				//限制年数，规则：无限制
	int			noticeNum;			//通知个数
	int			dayRemain;			//剩余天数
	int			yearRemain;			//剩余年数
	int			ooid;				//订单ID
	int			bindNum;				//绑定机器数| 选择列（1：QQ 2:PHONE 4:EMAIL 如果非零必须填写提交相应值，时原来规则，QQ或PHONE必须填写一个)查看时起作用
	int			activeNum;			//激活数 | 自定义表中选择的ID（制作时传输）|  自定义字段个数（查看时接收）
	int			otherset;	//1:查看时不显示条件信息（制作与查看） 2：无需再次申请（制作时）
	int			applyId; 	//申请的ID，如果重新申请，需提交该ID，离线阅读的申请也要提交该值。
    int			need_reapply;				//可能需要重新申请。
	int			iCanClient; 	//是否可以离线查看
	int			tableid;		//PC制作时，传输选择的exce表ID  |  //TODO:查看文件时，返回系列中文件总数
	int			fileversion;	//制作文件的版本，服务器端以此区分是否文件为三个结构体 | //TODO:查看文件时返回该文件所属系列ID
	int			need_showdiff;     //客户端显示，申请激活处理结果时，是否显示为不同效果。PC端变背景，移动端变字体颜色
	char			logName[USERNAME_LEN+1];		//!< 外发制作者登录名
	char			fileoutName[FILENAME_LEN+1];	//!< 文件外发名称
	char			startTime[TIME_LEN+1];			//!< 文件时效，开始时间yyyyMMdd
	char			endTime[TIME_LEN+1];			//!< 文件时效，结束时间yyyyMMdd
	char			MacAddr[MAC_LEN+1];				//!< 本机网卡MAC地址
	char			nick[NICK_LEN+1];			//卖家昵称（查看时下传）|机器名（制作时上传）
	char 		remark[REMARK_LEN+1];			//摘要
	char 		versionStr[VERSION_LEN+1];		//客户端版本
	char			email[EMAIL_LEN+1];				//邮箱，告诉对方联系方式
	char 		QQ[QQ_LEN+1];					//QQ，告诉对方联系方式
	char 		phone[PHONE_LEN+1];			//电话，告诉对方联系方式
	char			hardno[HARDNO_LEN+1];			//客户端硬件编码 |   制作时系列名
	char			sysinfo[SYSINFO_LEN+1];			//客户端系统信息
	unsigned char	HashValue [HASH_LEN];			//!< 文件hash
	unsigned char	EncodeKey[ENCRYPKEY_LEN];		//文件加密密钥
	unsigned char	SessionKey[ENCRYPKEY_LEN];		//会话密钥
	char			firstSeeTime[FIRST_SEE_TIME_LEN+1];		//初次查看时间
	char			outTime[FIRST_SEE_TIME_LEN+1];		//制作时间
	char			orderno[ORDERNO_LEN+1];				//制作返回订单号
    char        field1[FIELD_LEN+1];    //申请时需显示
    char        field2[FIELD_LEN+1];	//申请时需显示
    char			showInfo[SHOW_INFO_LEN+1];	//客户端显示，申请激活处理结果，未处理|处理结果
    char			messageId[MESSAGE_ID_LEN+1];	// 自由传播时，及获取验证码时传输验证码消息ID
    char			seriesname[SERIESNAME_LEN+1]; //查看时返回该文件所属系列名称
    char			notuse[NOT_USE_LEN_NEW_FILE];		//保留
}STRUCTDATA_NEW_NEW;


typedef struct _SEND_DATA_NEW_NEW
{
    short       type;       //发送的信息 类型
    
    short       suc;
    int       pos1;
    int       pos2;
    
    STRUCTDATA_NEW_NEW  userData;
}SENDDATA_NEW_NEW;

typedef struct _RECEIVE_DATA_NEW_NEW
{
    short       type;
    short       suc;        //成功标示
    
    int       pos1;
    int       pos2;
    
    STRUCTDATA_NEW_NEW  userData;
}RECEIVEDATA_NEW_NEW;

typedef struct _RECEIVE_DATA_
{
    short       type;
    short       suc;        //成功标示
    
    int       pos1;
    int       pos2;
    STRUCTDATA  userData;
}RECEIVEDATA;

typedef struct _STRUCT_DATA_NEW
{
    int fileOpenNum;           //文件打开次数限制
    int fileOpenedNum;          //已经打开的次数
    int bCanPrint;              //是否允许打印   0
    int iCanOpen;           //是否允许脱机打开 0bNotLinkOpen
    int ID;                     //数据库纪录的ID
    int             iOpenTimeLong;
    int             appType;
    int             random;
    int             version;
    int             dayNum;
    int             yearNum;
    int             noticeNum;
    int             dayRemain;
    int             yearRemain;
    int             ooid;
    int             notuse1;
    int             notuse2;
    int             notuse3;
    char logName[USERNAME_LEN +1];       //外发制作者的登陆名
    char fileoutName[FILENAME_LEN+1];   //被制作的文件名
    char startTime[TIME_LEN+1];         //有效开始日期 xxxx-xx-xx
    char endTime[TIME_LEN+1];           //有效结束日期
    char macAddr[MAC_LEN+1];            //本机网卡mac 地址
    char nick[NICK_LEN+1];//nick name
	char remark[REMARK_LEN + 1];//备注
    char versionStr[VERSION_LEN + 1];
    char email[VERSION_LEN + 1];
    char QQ[VERSION_LEN + 1];
    char phone[VERSION_LEN + 1];
    char hardno[VERSION_LEN + 1];
    char sysinfo[VERSION_LEN + 1];
    unsigned char HashValue[HASH_LEN];
    unsigned char EncodeKey[ENCRYPKEY_LEN];
    unsigned char SessionKey[ENCRYPKEY_LEN];
    char firstSeeTime[FIRST_SEE_TIME_LEN+1];
    unsigned char notUsed[NOT_USE_LEN_LEN];
    
}STRUCTDATA_NEW;

typedef struct _SEND_DATA_NEW
{
    short       type;       //发送的信息 类型
    
    short       suc;
    int       pos1;
    int       pos2;
    
    STRUCTDATA_NEW  userData;
}SENDDATA_NEW;

typedef struct _RECEIVE_DATA_NEW
{
    short       type;
    short       suc;        //成功标示
    
    int       pos1;
    int       pos2;
    STRUCTDATA_NEW  userData;
}RECEIVEDATA_NEW;
//文件头结构
typedef struct _TAG_PYC_FILE_HEAD_
{
    int64_t uTag;               //"PYC"
    int64_t fileSize;           //原文件大小
    int64_t encryptSize;        //加密长度（包含补齐的大小）
    Byte    extension[8];       //暂时不用
    
}PYCFILEHEADER;

//文件头扩展结构
typedef struct _TAG_PYC_FILE_EXT_
{
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    unsigned int uTag;
#else
    unsigned long uTag;               //"PYC"
#endif
    int     nFileId;
    unsigned char szSessionKey[SESSION_KEY_LEN];
    int     dwCrcValue;
    
}PYCFILEEXT;

typedef struct _OUTLINE_STRUCT
{
	int			structflag;			//固定值: 0x00435950
	int			applyid;				//申请ID，为0表示首次
	int			isClent;				//表示该文件为离线文件，现在只是赋值，不拿它判断是否为离线文件。
	int			actived;				//是否审核成功，为1表示已激活
	int			timeismodified;			//时间修改标记；如果检查到时间修改，该字段置为1，只有联网后置为0，如果是1那么就要求联网验证。
	int			fileopennum;			// 文件打开次数
	int			fileopenednum;		//文件已经被打开次数
	int			bCanPrint;			//文件是否允许打印
	int			daynum;				//限制天数，规则：无限制，天数值；年数值+10000
	int			yearnum;				//限制年数，规则：无限制
	int			iCanSeeCondition;		//是否能看限制条件
	int			chosenum;				//自定义信息选择QQ等情况
	int			fieldnum;				//自定义字段个数
	int			fieldprotect;			//自定义字段保密情况
	char		fileCreateTime[LONGTIME_LEN+1];		//文件产生时间
    char        fileModifyTime[LONGTIME_LEN+1];
	char		lastSeeTime[LONGTIME_LEN+1];		//最后查看时间
	char		endTime[LONGTIME_LEN+1];			//文件查看结束时间
	char		firstseeTime[LONGTIME_LEN+1];		//文件首次阅读时间
	char		QQ[QQ_LEN+1];					//申请输入的QQ
	char		email[EMAIL_LEN+1];				//申请输入的邮箱
	char 		phone[PHONE_LEN+1];				//申请输入的手机
	char		field1name[SELFDEFINE_LEN+1];			//自定义字段1名称
	char		field2name[SELFDEFINE_LEN+1];			//自定义字段2名称
	char		field1[SELFDEFINE_LEN+1];				//申请输入的自定义字段1
	char		field2[SELFDEFINE_LEN+1];				//申请输入的自定义字段2
	char		hardno[HARDNO_LEN +1];				//绑定机器码
    char        filename[FILENAME_LEN_OUTLINE +1];     //全文件名，首次能看时记录文件路径和名称
	unsigned char 	EncodeKey[ENCRYPKEY_LEN];		//文件加密钥
}OUTLINE_STRUCT,*LPOUTLINE_STRUCT;



typedef struct  _Make_Pyc_Receive_
{
    int returnValue;
    
}MAKEPYCRECEIVE;

















#endif

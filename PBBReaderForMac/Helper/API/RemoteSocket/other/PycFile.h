//
//  PycFile.h
//  PycSocket
//
//  Created by Fairy on 13-11-11.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileOutPublic.h"
#import "PycSocket.h"
#import "OutFile.h"


#define PYC_FILE_EXTENTION @"pbb"

@class PycFile;
@class PycSocket;

//#define TYPE_FILE_OUT                   100
//#define TYEP_FILE_SAVE_HASH_ENCRYPT     101
//#define TYPE_FILE_OPEN                  102
//#define TYPE_FILE_REFRESH               106
//#define TYPE_FILE_CHANGE_READ_CONDITION 104
//#define TYPE_FILE_CHANGE_FILE_CONTROLL  105

#define ERR_OK_OR_CANOPEN 1
#define ERR_OK_IS_FEE 2
#define ERR_NUM 4
#define ERR_DAY 8
#define ERR_SALER 16
#define ERR_APPLIED_AND_OVER 32
#define ERR_APPLIED 64
#define ERR_FREE 128
#define ERR_FEE_SALER 256
#define ERR_NEED_UPDATE 512
#define ERR_AUTO_APPLIED 2048

#define PycTag0 0x00435950
#define PycTag1 0x01435950

#define ERR_OUTLINE_OK 1
#define ERR_OUTLINE_HDID_ERR 32
#define ERR_OUTLINE_IS_OTHER_ERR 2
#define ERR_OUTLINE_NUM_ERR 4
#define ERR_OUTLINE_DAY_ERR 8
#define ERR_OUTLINE_TIME_CHANGED_ERR 128
#define ERR_OUTLINE_TIME_CHANGED_ALREADY_ERR 128
#define ERR_OUTLINE_OTHER_ERR 0
#define ERR_OUTLINE_STRUCTION_ERR 256


@protocol PycFileDelegate <NSObject>
@optional
-(void)PycFile:(PycFile *)fileObject didFinishRefreshPycFile:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishMakePycFile:(MAKEPYCRECEIVE *)receiveData;
//-(void)PycFile:(PycFile *)fileObject didFinishSeePycFile:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishSeePycFileForUser:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishChangeReadCondition:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishChangeFileControll:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishGetFileInfo:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishGetApplyFileInfo:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishClientFileInfo:(MAKEPYCRECEIVE *)receiveData;
//add by lry 2014-05-05
-(void)PycFile:(PycFile *)fileObject didFinishApply:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishReapply:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishGetOverList:(MAKEPYCRECEIVE *)receiveData;
-(void)PycFile:(PycFile *)fileObject didFinishGetVerificationCode:(MAKEPYCRECEIVE *)receiveData;
//add end

@end

@interface PycFile : NSObject<PycSocketDelegate>
//singleton_interface(PycFile)

@property (nonatomic, weak) id<PycFileDelegate> delegate;
@property(nonatomic, strong) PycSocket * pycsocket;
@property(nonatomic, copy)NSString *fileName;       //解密后，明文文件全路径/制作文件时，源文件的全路径
@property(nonatomic, copy)NSString *filePycNameFromServer;  // 带.pbb文件名称
@property(nonatomic, copy)NSString *filePycName;  // 文件路径
@property(nonatomic, copy)NSString *fileOwner;
@property(nonatomic,copy)NSString *fileSeeLogname;
@property(nonatomic, copy)NSString *startDay;
@property(nonatomic, copy)NSString *endDay;
@property(nonatomic, assign)NSInteger AllowOpenmaxNum;
@property(nonatomic,assign)NSInteger haveOpenedNum;  // 文件已经被打开次数
@property(nonatomic,assign)BOOL bCanprint;
@property(nonatomic,assign)NSInteger iCanOpen;//bNotlinkOpen;
@property(nonatomic, copy)NSString *nickname;
@property(nonatomic, copy)NSString *remark;
@property(nonatomic,assign)NSInteger seriesID;
@property(nonatomic,strong)NSString *seriesName;
@property(nonatomic,assign)NSInteger seriesFileNums;
@property(nonatomic, copy)NSString * versionStr;
@property(nonatomic,assign)NSInteger openTimeLong;//bNotlinkOpen;

@property(nonatomic, copy)NSString * orderNo;

@property(nonatomic, assign)NSInteger   fileID;
@property(nonatomic, strong)NSData      *fileHash;
@property(nonatomic, strong)NSData      *fileSecretkeyOrigianlR1;
@property(nonatomic, strong)NSData      *fileSessionkeyOrigianlRR2;
@property(nonatomic, strong)NSData      *fileSecretkeyR1;
@property(nonatomic, strong)NSData      *fileSessionkeyR2;

@property(nonatomic, assign)NSInteger   fileType;
@property(nonatomic, strong)NSString    *fileExtentionWithOutDot;

@property(nonatomic,strong)NSMutableArray *fileRefreshInfo;

@property(nonatomic,assign)BOOL bNeedBinding;  // 是否需要绑定
@property(nonatomic, copy)NSString * bindingPhone; // 买家绑定手机号
@property(nonatomic, copy)NSString * verificationCode; // 绑定手机号收到的验证码
@property(nonatomic, copy)NSString * verificationCodeID; // 绑定手机号收到的验证码ID
@property(nonatomic, copy)NSString * QQ;
@property(nonatomic, copy)NSString * email;
@property(nonatomic, copy)NSString * phone;
@property(nonatomic, copy)NSString * makeTime;
@property(nonatomic, copy)NSString * firstSeeTime;
@property(nonatomic,assign)NSInteger openDay;//bNotlinkOpen;
@property(nonatomic,assign)NSInteger openYear;//bNotlinkOpen;
@property(nonatomic,assign)NSInteger makeType;//bNotlinkOpen;
@property(nonatomic,assign)NSInteger Version;//bNotlinkOpen;
@property(nonatomic,assign)int Random;//bNotlinkOpen;
@property(nonatomic,assign)NSInteger dayRemain;//bNotlinkOpen剩余天数;
@property(nonatomic,assign)NSInteger yearRemain;//bNotlinkOpen剩余年数;
@property(nonatomic,assign)NSInteger orderID;//bNotlinkOpen;
@property(nonatomic,assign)NSInteger refreshType;//bNotlinkOpen;
@property(nonatomic,assign)NSInteger makeFrom;//制作端，18pc，28android,29wp,30iPhone
@property(nonatomic,assign)NSInteger bindNum;//绑定机器数
@property(nonatomic,assign)NSInteger activeNum;//激活数
@property(nonatomic,assign)NSInteger canseeCondition;//是否显示约束条件 1：不显示
@property(nonatomic, copy)NSString * field1; //自定义字段1
@property(nonatomic, copy)NSString * field2; //自定义字段2
@property(nonatomic,assign)NSInteger applyId; //激活id，为0表示首次
@property(nonatomic, copy)NSString *showInfo;  //
@property(nonatomic,assign) Byte *fileScreateR11;
@property(nonatomic,strong)NSMutableData *imageData;  //图片内存缓存

@property(nonatomic, copy)NSString * fild1name; //能查看时，自定义字段1名称
@property(nonatomic, copy)NSString * fild2name; //能查看时，自定义字段2名称
@property(nonatomic,assign)NSInteger selffieldnum;//自定义字段数
@property(nonatomic,assign)NSInteger openinfoid;//打开文件记录ID
@property(nonatomic,assign)NSInteger field1needprotect;//自定义字段1是否需要保密输入
@property(nonatomic,assign)NSInteger field2needprotect;//自定义字段2是否需要保密输入
@property(nonatomic,assign)NSInteger definechecked;//自定义字段时选择的QQ、EMAIL、PHONE结果
@property(nonatomic,assign)NSInteger iCanClient;  // 是否可以离线查看
@property(nonatomic,assign)NSInteger needReapply;  // 是否需要重新申请
@property(nonatomic,assign)NSInteger needShowDiff;  // 客户端显示，申请激活处理结果时，是否显示为不同效果。PC端变背景，移动端变字体颜色
@property(nonatomic,assign)NSInteger iResultIsOffLine;  // 是否可以离线查看
@property(nonatomic,assign)NSInteger isClient;  // 是否离线文件
@property(nonatomic,assign)long long encryptedLen;  // 加密长度
@property(nonatomic,assign)long long fileSize;     //文件长度
@property(nonatomic,assign)long long offset;       //解密密文开始位置

@property(nonatomic,assign)NSInteger timeType;  //手动激活时间限制，3

@property(nonatomic,copy)NSString *hardno;

@property(nonatomic,strong)OutFile *receiveFile;

-(BOOL)makePycFilePath: (NSString * )filePath fileOwner:(NSString *)fileowner startDay:(NSString *)startDay endDay:(NSString *)endday maxOpenNum:(NSInteger) openNumMax  remark:(NSString *)theRemark version:(NSString *)version duration:(NSInteger)duration qq:(NSString *)theQQ email:(NSString *)theEmail phone:(NSString *)thePhone maxOpenday:(NSInteger )theOpenDay maxOpenyear:(NSInteger )theOpenYear makeType:(NSInteger)theMakeType;

-(BOOL)seePycFile:(NSString *)pycFileName
          forUser:(NSString *)logname
          pbbFile:(NSString *)pbbFileName
          phoneNo:(NSString *)phoneNo
        messageID:(NSString *)messageID
        isOffLine:(BOOL*)bIsOFFLine
    FileOpenedNum:(NSInteger)openedNum;

-(NSString *)seePycFile2:(NSString *)pycFileName
forUser:(NSString *)logname
pbbFile:(NSString *)pbbFileName
phoneNo:(NSString *)phoneNo
messageID:(NSString *)messageID
isOffLine:(BOOL*)bIsOFFLine
FileOpenedNum:(NSInteger)openedNum;
//when make pyc file
//add remark
//remove foruser
//-(BOOL)makePycFilePath: (NSString * )filePath fileOwner:(NSString *)fileowner startDay:(NSString *)startDay endDay:(NSString *)endday maxOpenNum:(NSInteger) openNumMax  remark:(NSString *)theRemark  version:(NSString *)theVersion;

//remove foruser
//-(BOOL)seePycFile:(NSString *)pycFileName;

//对应 得到需要刷新的文件信息，结果保存在fileRefreshInfo数组中，其中数组中的每个变量的类型是refreshDataModel类的（refreshDataModel.h）,theListType:0,发送列表；1，接收列表
-(BOOL)refreshListInfoByFileId:(NSArray *)fileIds listType:(NSInteger) theListType;

//终止阅读和取消终止 可以打开是 FILE_READ_CONDITION_CANOPEN 不可以打开始 FILE_READ_CONDITION_CANNOTOPEN
-(BOOL)changePycFileReadCondition:(NSInteger ) OpenCondition forFileId:(NSInteger )fileId forUser:(NSString *)fileowner;

//修改文件的控制条件 openTimeLong 暂时不使用，填写0 即可
-(BOOL)changePycFileStartDay:(NSString *)startDay endDay:(NSString *)endDay allowOpenedMaxNum:(NSInteger )allowOpenMaxNum openTimeLong:(NSInteger)openTimeLong remark:(NSString *)remark   forFileId:(NSInteger )fileId forUser:(NSString *)fileowner duration:(NSInteger)duration qq:(NSString *)theQQ email:(NSString *)theEmail phone:(NSString *)thePhone;

// 申取验证码
-(BOOL)getVerificationCodeByPhone:(NSString *)phone userPhone:(BOOL)userPhone;

//得到文件的fileid属性
- (int)getAttributePycFileId:(NSString *)filename;

//发送给服务器文件阅读结束
- (void)sendSeeOverTime:(NSInteger )fileId openInfoID:(NSInteger) theOpenInfoID;

//离线验证
-(BOOL)ClientFileById:(NSInteger )applyID fileOpenedNum:(NSInteger) fileOpenedNum;
//得到文件的所有信息,theFileType:0,发送文件；1，接收文件
-(BOOL)getFileInfoById:(NSInteger )theFileId pbbFile:(NSString *)pbbFileName PycFile:(NSString *)pycFileName fileType:(NSInteger) theFileType;
//得到文件申请激活信息
-(BOOL)getApplyFileInfoByApplyId:(NSInteger)applyId FileID:(NSInteger)fileID;
//申请手动激活
- (NSString *)applyFileByFidAndOrderId:(NSInteger )fileId orderId:(NSInteger )thOrderId qq:(NSString *)theQQ email:(NSString *)theEmail phone:(NSString *)thePhone field1:(NSString *)theField1 field2:(NSString *)theField2 seeLogName:(NSString *)theSeeLogName fileName:(NSString*)theFileName;
//重新申请手动激活
- (NSString *)reapplyFileByFidAndOrderId:(NSInteger )fileId orderId:(NSInteger )thOrderId applyId:(NSInteger)applyId qq:(NSString *)theQQ email:(NSString *)theEmail phone:(NSString *)thePhone  field1:(NSString *)theField1 field2:(NSString *)theField2;
//查看激活用完记录
- (BOOL)seeAppliedAndOverListByFid:(NSInteger )fileId;
//生成申请发送数据
-(void)MakeapplyFileByFidAndOrderIdPackage:(SENDDATA_NEW_NEW *)data;
//生成重新申请发送数据
//-(void)MakereapplyFileByFidAndOrderIdPackage:(SENDDATA_NEW_NEW *)data;
//生成激活用完记录发送数据
-(void)MakeseeAppliedAndOverListByFidPackage:(SENDDATA_NEW_NEW *)data;
//解析激活用完记录接收数据
-(void)receiveseeAppliedAndOverListByFidPackage:(RECEIVEDATA_NEW_NEW *)receiveData;
//加密网页传输参数
-(void)codeUrl:(NSString *)sUrl dUrl:(void (^)(NSString *))dUrl;
-(void)codeUrlnew:(NSString *)sUrl dUrl:(void (^)(NSString *))dUrl;
//修改文件离线结构
-(BOOL)setOutLineStructData:(NSString *)filename isFirstSee:(NSInteger) bFirstSee isSetFirst:(NSInteger)bSetFirst isSee:(NSInteger)bSee isVerifyOk:(NSInteger)bVerifyOk isTimeIsChanged:(NSInteger)bTimeIsChanged isApplySucess:(NSInteger)bApplySucess  data:(RECEIVEDATA_NEW_NEW *)theData;
//是否可以查看离线文件
-(int)isOutLineFileCanSee:(NSString*)fileName remainDay:(NSInteger*)theRemainDay remainYear:(NSInteger *)theRemainYear;
//是否需要联网
-(BOOL)isFileNeedNet:(NSString*)fileName applyID:(NSInteger *)theApplyID;
//根据返回值修改离线文件的离线结构
-(BOOL)modifySourceFileByOutlineValue:(NSInteger)value filename:(NSString*) theFileName;
//从离线结构中取数据赋值以便查看文件
-(BOOL)setSeeInfoFromOutLineStru:(NSString*)filename;

/**
 * @brief 完善个人信息，绑定手机号
 * @param phoneNum 手机号
 *
 */
-(BOOL)bindPhoneByVerificationCode:(NSString *)verificationCode logname:(NSString *)logname messageId:(NSString *)messageId;
@end

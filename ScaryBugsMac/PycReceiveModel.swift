//
//  PycReceiveModel.swift
//  ScaryBugsMac
//
//  Created by pengyucheng on 16/6/1.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

class PycReceiveModel: NSObject {

    var fileName = ""       //解密后，明文文件全路径/制作文件时，源文件的全路径
    var filePycNameFromServer = ""  // 带.pbb文件名称
    var filePycName = ""  // 文件路径
    var fileOwner = ""
    var fileSeeLogname = ""
    var startDay = ""
    var endDay = ""
    var  AllowOpenmaxNum = 0
    var haveOpenedNum = 0  // 文件已经被打开次数
    var bCanprint = false
    var iCanOpen = 0//bNotlinkOpen;
    var nickname = ""
    var remark = ""
    var seriesID = 0
    var seriesName = ""
    var seriesFileNums = 0
    var  versionStr = ""
    var openTimeLong = 0//bNotlinkOpen;
    
    var  orderNo = ""
    
    var    fileID = 0
    var fileHash:NSData?
    var fileSecretkeyOrigianlR1:NSData?
    var fileSessionkeyOrigianlRR2:NSData?
    var fileSecretkeyR1:NSData?
    var fileSessionkeyR2:NSData?
    
    var    fileType = 0
    var fileExtentionWithOutDot = ""
    
    var fileRefreshInfo:[AnyObject]?
    
    var bNeedBinding = false  // 是否需要绑定
    var  bindingPhone = "" // 买家绑定手机号
    var  verificationCode = "" // 绑定手机号收到的验证码
    var  verificationCodeID = "" // 绑定手机号收到的验证码ID
    var  QQ = ""
    var  email = ""
    var  phone = ""
    var  makeTime = ""
    var  firstSeeTime = ""
    var openDay = 0//bNotlinkOpen;
    var openYear = 0//bNotlinkOpen;
    var makeType = 0//bNotlinkOpen;
    var Version = 0//bNotlinkOpen;
    var Random = 0//bNotlinkOpen;
    var dayRemain = 0//bNotlinkOpen剩余天数;
    var yearRemain = 0//bNotlinkOpen剩余年数;
    var orderID = 0//bNotlinkOpen;
    var refreshType = 0//bNotlinkOpen;
    var makeFrom = 0//制作端，18pc，28android,29wp,30iPhone
    var bindNum = 0//绑定机器数
    var activeNum = 0//激活数
    var canseeCondition = 0//是否显示约束条件 1：不显示
    var  field1 = "" //自定义字段1
    var  field2 = "" //自定义字段2
    var applyId = 0 //激活id，为0表示首次
    var showInfo = ""  //
//    @property(nonatomic,assign) Byte *fileScreateR11;
//    @property(nonatomic,strong)NSMutableData *imageData;  //图片内存缓存
    
    var  fild1name = "" //能查看时，自定义字段1名称
    var  fild2name = "" //能查看时，自定义字段2名称
    var selffieldnum = 0//自定义字段数
    var openinfoid = 0//打开文件记录ID
    var field1needprotect = 0//自定义字段1是否需要保密输入
    var field2needprotect = 0//自定义字段2是否需要保密输入
    var definechecked = 0//自定义字段时选择的QQ、EMAIL、PHONE结果
    var iCanClient = 0  // 是否可以离线查看
    var needReapply = 0  // 是否需要重新申请
    var needShowDiff = 0  // 客户端显示，申请激活处理结果时，是否显示为不同效果。PC端变背景，移动端变字体颜色
    var iResultIsOffLine = 0  // 是否可以离线查看
    var isClient = 0  // 是否离线文件
//    @property(nonatomic,assign)long long encryptedLen;  // 加密长度
//    @property(nonatomic,assign)long long fileSize;     //文件长度
//    @property(nonatomic,assign)long long offset;       //解密密文开始位置
    
    var timeType = 0  //手动激活时间限制，3
    
    var hardno = ""
    
    var receiveFile:OutFile?
}

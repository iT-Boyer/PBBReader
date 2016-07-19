//
//  OutFileModel.swift
//  ScaryBugsMac
//
//  Created by huoshuguang on 16/6/4.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Foundation
import RealmSwift
class OutFileModel:Object{
    //
    //数据库存储主键ID
    dynamic var sqlid = 0
    override static func primaryKey() -> String?
    {
        return "sqlid"
    }
    //服务器放回的文件ID
    dynamic var fileid = 0
    //文件名
    dynamic var filename = ""
    //文件的本地存储路径
    dynamic var fileurl = ""
    //文件类型（图片，视频，文档等）暂时以文件后缀代替
    dynamic var filetype = ""
    //文件所属的用户名
    dynamic var fileowner = ""
    //账号
    dynamic var logname = ""
    
    //起始限制时间
    dynamic var starttime:NSDate?
    //接受限制时间
    dynamic var endtime:NSDate?
    //限制查阅秒数
    dynamic var  limittime = 0
    
    //是否终止 制作者 1：开放，0：终止
    dynamic var  forbid = 0
    //限制阅读的总次数
    dynamic var  limitnum = 0
    //已读次数
    dynamic var  readnum = 0
    
    //文件备注
    dynamic var note = ""
    
    //制作者Nick
    dynamic var fileOwnerNick = ""
    //列表信息字段
    //剩余可读次数
    dynamic var  lastnum = 0
    //剩余可读天数
    dynamic var  lasttime = 0
    //剩余可读天数
    dynamic var  lastday = 0
    //总共可读天数
    dynamic var  allday = 0
    //文件的打开状态 0未打开，1 已打开 2 终止
    dynamic var  open = 0
    //是否禁止查阅 NO:禁止 ,YES :未禁止
    dynamic var status = false
    //手动激活文件，当前权限状态
    dynamic var canSeeForOutline = 0
    
    ////天数是否限制：NO：不限制 ，YES：限制
    dynamic var freetime = false
    //次数是否限制： NO：不限制 ，YES：限制
    dynamic var freenum = false
    
    // qq:@"1" email:@"a" phone:@"a" maxOpenday:0 maxOpenyear:0 makeType:1
    dynamic var fileQQ = ""
    dynamic var fileEmail = ""
    dynamic var filePhone = ""
    dynamic var  fileOpenDay = 0      //总天数
    dynamic var  fileOpenYear = 0     //总年数
    dynamic var  fileDayRemain = 0   //剩余天数
    dynamic var  fileYearRemain = 0  //剩余年数
    dynamic var  fileMakeType = 0  //1：自由传播 0：手动激活
    
    dynamic var  fileBindMachineNum = 0
    dynamic var  fileActivationNum = 0
    
    dynamic var firstOpenTime = ""
    
    dynamic var isEye = false  //买家是否能看到限制条件，1：能看，0：不可见
    
    dynamic var  fileTimeType = 0 //fileTimeType=4时，表示采用时间段限制条件
    
    //send
    dynamic var sendtime:NSDate?   //相当于 接收表中的makeTime
    dynamic var orderNum = ""
    
    //receive
    dynamic var reborn = 0 //0:未使用  1:已使用过
    dynamic var recevieTime:NSDate? //相当于 接收表中的firstOpenTime
    dynamic var appType = ""
    
    /**
     *  离线文件结构体属性
     */
    dynamic var  applyId = 0
    dynamic var  actived = 0
    dynamic var field1 = ""
    dynamic var field2 = ""
    dynamic var field1name = ""
    dynamic var field2name = ""
    dynamic var hardno = ""
    dynamic var EncodeKey:NSData?
    dynamic var selffieldnum = 0//自定义字段数
    dynamic var definechecked = 0//自定义字段时选择的QQ、EMAIL、PHONE结果
    
    dynamic var waterMarkQQ = ""
    dynamic var waterMarkPhone = ""
    dynamic var waterMarkEmail = ""
    dynamic var  seriesID = 0
    dynamic var lastSeeTime:NSDate?
    dynamic var  isChangedTime = 0
}
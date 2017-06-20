//
//  VerificationCodeDao.m
//  PBB
//
//  Created by pengyucheng on 15/1/30.
//  Copyright (c) 2015年 pyc.com.cn. All rights reserved.
//

#import "VerificationCodeDao.h"
#import "DataFactory.h"

@implementation VerificationCodeDao

singleton_implementation(VerificationCodeDao)


/**
 *  保存服务器每一返回的验证码
 */

-(void)insertVerificationCode:(VerificationCodeModel *)model
{
    NSLog(@"%s", __func__);
    model.reciveTime = [[NSDate date] dateByAddingTimeInterval:+5*60];
    [[DataFactory shardDataFactory] insertToDB:model Classtype:VerificationCode];
}

/**
 * @b 根据 短信验证码查询&seeFile类型 本地验证码
 * @p model
 * @return messageId
 */

-(NSString *)searchVerificationCodeOfMessageId:(VerificationCodeModel *)model
{
    NSLog(@"%s", __func__);
    NSString *result = nil;
    NSMutableDictionary *whereDic = [[NSMutableDictionary alloc] init];
    [whereDic setValue:model.seeFile forKey:@"seeFile"];
    [whereDic setValue:model.verificationCode forKey:@"verificationCode"];
    __block NSArray *resultArr=nil;
    [[DataFactory shardDataFactory] searchWhere:whereDic orderBy:nil offset:0 count:0 Classtype:VerificationCode callback:^(NSArray *arr) {
        resultArr = arr;
    }];
    
    if([resultArr count]>0){
        
        VerificationCodeModel *codeModel = [resultArr objectAtIndex:0];
        //是否超时
        if ([[codeModel.reciveTime laterDate:[NSDate date]] isEqualToDate:codeModel.reciveTime]) {
            //没超时返回messageId
            result = codeModel.messageId;
        }
        
    }else{
        //没有记录时,即验证码无效了
        return nil;
    }

    
    return result;
}


/**
 *  通过短信验证码，成功绑定手机号或成功激活文件后，清空同类别的验证码
 */

-(void)deleteVerificationCode:(BOOL)userPhone
{
    NSLog(@"%s", __func__);
    NSMutableDictionary *delDic = [[NSMutableDictionary alloc] init];
    if (userPhone) {
        [delDic setValue:@"1" forKey:@"seeFile"];
    }else{
        [delDic setValue:@"0" forKey:@"seeFile"];
    }
    [[DataFactory shardDataFactory] deleteWhereData:[delDic copy] Classtype:VerificationCode];
    
}

/**
 *
 * 退出应用清空短信验证码的所有记录
 *
 */
-(void)clearVerificationCode:(VerificationCodeModel *)model
{
    NSLog(@"%s", __func__);
    [[DataFactory shardDataFactory] clearTableData:VerificationCode];
    
}






@end

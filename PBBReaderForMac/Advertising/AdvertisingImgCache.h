//
//  AdvertisingImgCache.h
//  PBB
//
//  Created by pengyucheng on 14/12/9.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AdvertisingCompletionBlock)(NSString *imgPath,NSInteger uid, NSError *error);

@interface AdvertisingImgCache : NSObject

//获取数据
- (void)AdvertisingForTerm:(NSString *)UidOrImgURL completionBlock:(AdvertisingCompletionBlock) completionBlock;
@end

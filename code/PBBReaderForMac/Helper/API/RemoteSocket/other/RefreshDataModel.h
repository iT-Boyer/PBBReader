//
//  refreshDataModel.h
//  PBB
//
//  Created by Fairy on 13-12-2.
//  Copyright (c) 2013年 pyc.com.cn. All rights reserved.
//



@interface RefreshDataModel : NSObject

@property (nonatomic, assign)NSNumber *fileId;
@property (nonatomic, assign)NSNumber *canseeCondition;
@property(nonatomic, assign)NSNumber *AllowOpenmaxNum;
@property(nonatomic,assign)NSNumber *haveOpenedNum;
@property(nonatomic, copy)NSString *startDay;
@property(nonatomic, copy)NSString *endDay;
@property(nonatomic,assign)NSNumber *openTimeLength;
@property(nonatomic,assign)NSNumber *iCanOpen;
@property(nonatomic,assign)NSNumber *makeType;
@property(nonatomic, copy)NSString *makeTime;
@property(nonatomic,assign)NSNumber *isClient;

@property(nonatomic,assign)NSNumber *bandNum;
@property(nonatomic,assign)NSNumber *activeNum;
@property(nonatomic,assign)NSNumber *openDay;
@property(nonatomic,assign)NSNumber *remanDay;
@property(nonatomic,assign)NSNumber *openYear;
@property(nonatomic,assign)NSNumber *remainYear;
@property(nonatomic, copy)NSString *firstReadTime;


@end
@interface SeeApplyEndListDataModel : NSObject

@property (nonatomic, assign)NSNumber *fileOpenNum;
@property(nonatomic, assign)NSNumber *fileOpenedNum;
@property(nonatomic,assign)NSNumber *dayNum;
@property(nonatomic,assign)NSNumber *dayRemain;
@property(nonatomic,assign)NSNumber *yearNum;
@property(nonatomic,assign)NSNumber *yearRemain;
@property(nonatomic, copy)NSString *firstSeeTime;
@end

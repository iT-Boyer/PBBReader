//
//  PycSocket.h
//  PycSocket
//
//  Created by Fairy on 13-11-11.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "FileOutPublic.h"
#define SOCKET_TIME_OUT -1


@class PycSocket;

@protocol PycSocketDelegate <NSObject>

//连接结束，服务器返回数据
-(void)PycSocket: (PycSocket *)fileObject didFinishSend: (Byte *)receiveData;
//连接成功，打包并发送数据
-(void)PycSocket: (PycSocket *)fileObject didFinishConnect: (Byte *)receiveData;


@end


@interface PycSocket : NSObject

@property(nonatomic, assign)NSInteger connectType;
@property(nonatomic, assign)NSInteger receiveDataLength;
@property (nonatomic,assign)BOOL bOkConnect;
@property (nonatomic, weak) id<PycSocketDelegate> delegate;
//- (void)connectToServer;
-(id)initWithDelegate:(id)theDelegate;
-(BOOL) connectToServer:(NSString *) ip port:( NSInteger )port;
- (NSInteger)SocketWrite:(Byte*)data length:(int) len receiveDataLength:(NSInteger)receiveDataLength;
- (void)SocketClose;

@end

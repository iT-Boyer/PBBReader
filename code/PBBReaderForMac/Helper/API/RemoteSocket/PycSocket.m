//
//  PycSocket.m
//  PycSocket
//
//  Created by Fairy on 13-11-11.
//  Copyright (c) 2013年 Fairy. All rights reserved.
//

#import "PycSocket.h"
#import "GCDAsyncSocket.h"
#import "PycCode.h"
#import "PycFolder.h"
#import "PycFile.h"



@interface PycSocket()<GCDAsyncSocketDelegate>

@property(strong,nonatomic) GCDAsyncSocket *GCDSocket;

@end
@implementation PycSocket
{
    NSMutableData *restData;
    NSString *hostIP;
    uint16_t hostPort;
    NSInteger dataTag;
}

#pragma mark - init method
- (id)init
{
    self = [super init];
    if (self)
    {
       // [self connectToServer];
        NSLog(@"init GCDScoket---");
        
    }
    return self;
}

-(id)initWithDelegate:(id)theDelegate
{
    if(self = [super init])
    {
        self.delegate = theDelegate;
    }

    return self;
}

#pragma mark - 建立socket连接

-(BOOL)connectToServer:(NSString *) ip port:(NSInteger)port
{

    hostIP = ip;
    hostPort = port;
    
    NSError *err = [self setupConnection];
    if (err) {
        return NO;
    }
    return YES;
    
}

//GCD建立连接
-(NSError *)setupConnection{
    
    if (_GCDSocket!=nil) {
        [self SocketClose];
    }

    _GCDSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
   
    NSError *err = nil;
    NSLog(@"IP: %@, port:%i",hostIP,hostPort);
    if (![_GCDSocket connectToHost:hostIP onPort:hostPort error:&err]) {
        NSLog(@"Connection error : %@",err);
    } else {
        err = nil;
    }
    return err;
}


#pragma mark - 开始数据传输

- (NSInteger)SocketWrite:(Byte*)data length:(int) len receiveDataLength:(NSInteger)receiveDataLength
{
    self.receiveDataLength = receiveDataLength;
    BOOL suc = 0;
    if ([_GCDSocket isConnected]) {
        NSData *sendData = [[NSData alloc]initWithBytes:(Byte *)data length:len];
        NSLog(@"发出请求数据...总包长度receiveDataLength：%ld",(long)receiveDataLength);
        [_GCDSocket writeData:sendData withTimeout:20 tag:0];
//        [_GCDSocket disconnectAfterReadingAndWriting];
        suc = 1;
    }
    NSLog(@"suc : %d",suc);
    return suc;
}


#pragma mark - AsyncSocketDelegate 

//socket连接成功后的回调代理
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"socket：%p，连接成功",sock);
    self.bOkConnect = YES;
    //这是异步返回的连接成功，执行self SocketWrite:length 方法，开始数据传输
    [self.delegate PycSocket:self didFinishConnect:nil];
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"发出请求数据...结束，socket:%p didWriteDataWithTag:%ld", sock, tag);
    dataTag = 0;
//    [_GCDSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
    
    [_GCDSocket readDataWithTimeout:20 tag:0];
    NSLog(@"首次发起获取数据请求");
//    [_GCDSocket disconnectAfterReadingAndWriting];
}
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"第 %ld 次，发送数据长度：%lu",tag,(unsigned long)partialLength);
}

-(void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"第 %ld 次，获取数据长度：%lu",tag,(unsigned long)partialLength);
}
//读到数据后的回调代理
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"接收包.....tag:%ld",(long)dataTag);
    //拼接包
//    if(tag == dataTag)
        [self splitData:data];
    
}

//socket连接断开后的回调代理
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socket：%p,已关闭,总包长度：%lu",sock,(unsigned long)[restData length]);
    
    RECEIVEDATA *p = (RECEIVEDATA *)[restData bytes];
    //成功了制作文件
    [self.delegate PycSocket:self didFinishSend:(Byte*)p];
    
    restData = nil;
    self.bOkConnect = NO;
}

//断开连接
-(void)SocketClose
{
    NSLog(@"Socket:%p强制断开",_GCDSocket);
    self.bOkConnect = NO;
    [_GCDSocket disconnect];
    [_GCDSocket setDelegate:nil];
//    [_GCDSocket disconnectAfterReadingAndWriting];
    
    _GCDSocket=nil;
}
//分割数据包
-(void)splitData:(NSData*)orignal_data {
    
    NSUInteger l = [orignal_data length];
    NSLog(@"Data length1 = %lu",(unsigned long)l);
    if (restData == nil) {
        restData = [[NSMutableData alloc] init];
    }
    [restData appendData:orignal_data];
    [self readData];
 }

-(void)readData
{
    NSLog(@"写入后总data长度:%lu,socket:%p ,tag= %ld",(unsigned long)[restData length],_GCDSocket,(long)dataTag);
    if ([restData length] < self.receiveDataLength && dataTag < 4) {
        
        //        [_GCDSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:dataTag++];
        [_GCDSocket readDataWithTimeout:20 tag:dataTag++];
        NSLog(@"第%ld次，发起获取数据请求",(long)dataTag);
    }else{
        
        if ([restData length] < self.receiveDataLength)
        {
            //超过四次数据接收，总数据包长度仍小与receiveDataLength，不再进行接收，数据置空，认为网络不好
            restData = nil;
        }
        if ([_GCDSocket isConnected]) {
            [self SocketClose];
        }
    }
    
}
//分割数据包
-(void)splitData1:(NSData*)orignal_data {
    
    NSUInteger l = [orignal_data length];
    NSLog(@"Data length1 = %lu",(unsigned long)l);
    NSString* sp = @"\n";
    NSData* sp_data = [sp dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger sp_length = [sp_data length];
    NSUInteger offset = 0;
    int line = 0;
    while (TRUE) {
        //查找指定的数据包的位置
        NSUInteger index = [self indexOfData:sp_data inData:orignal_data offset:offset];
        //未查到的新包，执行拼接
        NSRange ra = {0,index};
        NSLog(@"拼接新数据前，总包长度:%lu,查找指定的新数据包的位置:%lu",(unsigned long)[restData length],(unsigned long)ra.length);
        if (NSNotFound == index) {
            if (offset<l) {
                NSRange range = {offset,l-offset};
                NSData* rest = [orignal_data subdataWithRange:range];
                NSLog(@"有新数据长度：%lu,写入包",(unsigned long)[rest length]);
                if (restData == nil) {
                    restData = [[NSMutableData alloc] init];
                }
                [restData appendData:rest];
                [self readData];
            }
            
            return;
        }
        
        //已拼接过的数据包
        NSUInteger length = index + sp_length;
        NSRange range = {offset,length-offset};
        NSLog(@"从部分已拼接过的数据包中，未拼接的数据包的range：location：%lu，length:%lu",(unsigned long)offset,length-offset);
        NSData* sub = [orignal_data subdataWithRange:range];
        
        //
        if (restData != nil) {
            //拼包
            [restData appendData:sub];
            [self readData];
        } else {
            NSLog(@"----line %d,包长度:%lu",line++,(unsigned long)[sub length]);
            restData = [[NSMutableData alloc] init];
            [restData appendData:sub];
            [self readData];
        }
        offset += length;
    }
}




//查找指定的数据包的位置
- (NSUInteger)indexOfData:(NSData*)needle inData:(NSData*)haystack offset:(NSUInteger)offset
{
    Byte* needleBytes = (Byte*)[needle bytes];
    Byte* haystackBytes = (Byte*)[haystack bytes];
    
    // walk the length of the buffer, looking for a byte that matches the start
    // of the pattern; we can skip (|needle|-1) bytes at the end, since we can't
    // have a match that's shorter than needle itself
    for (NSUInteger i=offset; i < [haystack length]-[needle length]+1; i++)
    {
        // walk needle's bytes while they still match the bytes of haystack
        // starting at i; if we walk off the end of needle, we found a match
        NSUInteger j=0;

        while (j < [needle length] && needleBytes[j] == haystackBytes[i+j])
        {
            j++;
        }
        if (j == [needle length])
        {
            return i;
        }
    }
    return NSNotFound;
}

/*连接断开失败
 - (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
 {
 NSLog(@"socket连接断开失败");
 }
 
 - (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
 {
 
 //  NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 NSLog(@"receive data");
 RECEIVEDATA *p = (RECEIVEDATA *)[data bytes];
 
 if (!p) {
 NSLog(@"socket服务器返回空值");
 goto ALL_END;
 }
 
 //成功了  制作文件
 [self.delegate PycSocket:self didFinishSend:(Byte*)p];
 
 [self SocketClose];
 
 ALL_END:
 
 [sock readDataWithTimeout:SOCKET_TIME_OUT  tag:0];
 }
 //连接已关闭
 - (void)onSocketDidDisconnect:(AsyncSocket *)sock
 {
 
 NSLog(@"socket已断开连接");
 if (!self.bOkConnect) {
 [self.delegate PycSocket:self didFinishSend:nil];
 }
 self.bOkConnect = NO;
 
 }
 */
@end

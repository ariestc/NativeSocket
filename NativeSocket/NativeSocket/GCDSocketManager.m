//
//  GCDSocketManager.m
//  NativeSocket
//
//  Created by wangliang on 2018/1/2.
//  Copyright © 2018年 wangliang. All rights reserved.
//

#import "GCDSocketManager.h"
#import "GCDAsyncSocket.h"

static NSString *mgrHost=@"127.0.0.1";
static const uint16_t mgrport=1358;

@interface GCDSocketManager ()<GCDAsyncSocketDelegate>

@property(nonatomic,strong) GCDAsyncSocket  *gcdAsyncSocket;

@end

@implementation GCDSocketManager

+(instancetype)shareManager
{
    static GCDSocketManager *instance=nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance=[[self alloc] init];
        
        [instance initSocket];
    });
    
    return instance;
}

-(void)initSocket
{
    _gcdAsyncSocket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}
#pragma mark --  GCDAsyncSocketDelegate
//invote when connect success
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"connect success host:%@,port:%d",host,port);
    
    [self pullLatestMessage];
    
    //heartbeat
    
}

//disConnect
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"disConnect,host:%@,port:%d",sock.localHost,sock.localPort);
    
    //connect again
}

//receive message
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
   NSString *msg=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"msg=%@",msg);
    
    [self pullLatestMessage];
}

#pragma mark --  method

-(void)pullLatestMessage
{
    [self.gcdAsyncSocket readDataWithTimeout:-1 tag:0];
}

-(BOOL)connect
{
    return [self.gcdAsyncSocket connectToHost:mgrHost onPort:mgrport error:nil];
}

-(void)sendMessage:(NSString *)msg
{
    NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.gcdAsyncSocket writeData:data withTimeout:-1 tag:0];
}

-(void)disConnect
{
    [self.gcdAsyncSocket disconnect];
}


@end

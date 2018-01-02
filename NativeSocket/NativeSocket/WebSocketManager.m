//
//  WebSocketManager.m
//  NativeSocket
//
//  Created by wangliang on 2018/1/2.
//  Copyright © 2018年 wangliang. All rights reserved.
//

#import "WebSocketManager.h"
#import <SocketRocket.h>

#define  dispatch_main_async_safe(block)\
        if ([NSThread isMainThread]) {\
            block();\
        }else{\
            dispatch_async(dispatch_get_main_queue(), block);\
        }

static NSString *mgrHost=@"127.0.0.1";

static const uint16_t mgrPort=1358;

@interface WebSocketManager()<SRWebSocketDelegate>

@property(nonatomic,strong) SRWebSocket *webSocket;

@property(nonatomic,strong) NSTimer *timer;

@property(nonatomic,assign) NSTimeInterval repeatConnectTime;

@end

@implementation WebSocketManager

+(instancetype)shareManager
{
    static WebSocketManager *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance=[[self alloc] init];
        
        [instance initSocket];
        
    });
    
    return instance;
}

#pragma mark -- SRWebSocketDelegate

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"server return receive message: %@",message);
}

//connect Success
-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"connect success ");
    
    [self setupHeartBeat];
}

//when connect fail ,repeat connect
-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"connect fail ...%@",error);
    
    [self repeatConnect];
}

//invoke when network interruption
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"connect close,code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    if (code == disConnectByUser) {
        
        [self disConnect];
    }else{
        
        [self repeatConnect];
    }
    
    [self cancelHeartBeat];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"receive pong callback");
}

-(void)repeatConnect
{
    [self disConnect];
    
    // beyong one minute stop connect repeat five times
    if (_repeatConnectTime > 64) {
        
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_repeatConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _webSocket=nil;
        
        [self initSocket];
    });
    
    if (_repeatConnectTime == 0) {
        
        //first setup two second
        _repeatConnectTime=2;
    }else{
        
        _repeatConnectTime *=2;
    }
}

#pragma mark -- method

-(void)connect
{
    [self initSocket];
    
    self.repeatConnectTime=0;
}

-(void)sendMessage:(NSString *)msg
{
    [self.webSocket send:msg];
}

-(void)disConnect
{
    if (_webSocket) {
        
        [_webSocket close];
        
        _webSocket=nil;
    }
}

-(void)ping
{
    [_webSocket sendPing:nil];
}

-(void)setupHeartBeat
{
    dispatch_main_async_safe(^{
        
        [self cancelHeartBeat];
        
        __weak typeof(self) weakSelf=self;
        //three minute
        _timer=[NSTimer scheduledTimerWithTimeInterval:3 * 60 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            //aries is heartBeat identify
            [weakSelf sendMessage:@"aries"];
        }];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    })
    
}

-(void)cancelHeartBeat
{
    dispatch_main_async_safe(^{
        
        if (_timer) {
            
            [_timer invalidate];
            
            _timer=nil;
        }
    })
}

-(void)initSocket
{
    if (_webSocket) {
        
        return;
    }
    
    _webSocket=[[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%d",mgrHost,mgrPort]]];
    
    _webSocket.delegate=self;
    
    NSOperationQueue *queue=[[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount=3;
    
    [_webSocket setDelegateOperationQueue:queue];
    
    //connect
    [_webSocket open];
}


@end

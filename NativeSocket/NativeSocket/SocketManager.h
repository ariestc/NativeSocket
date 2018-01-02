//
//  SocketManager.h
//  NativeSocket
//
//  Created by wangliang on 2018/1/2.
//  Copyright © 2018年 wangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketManager : NSObject

+(instancetype)shareManager;

-(void)connect;

-(void)disConnect;

-(void)sendMessage:(NSString *)msg;

@end

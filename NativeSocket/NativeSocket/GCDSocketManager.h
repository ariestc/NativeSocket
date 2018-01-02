//
//  GCDSocketManager.h
//  NativeSocket
//
//  Created by wangliang on 2018/1/2.
//  Copyright © 2018年 wangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDSocketManager : NSObject

+(instancetype)shareManager;

-(BOOL)connect;

-(void)disConnect;

-(void)sendMessage:(NSString *)msg;

-(void)pullLatestMessage;

@end

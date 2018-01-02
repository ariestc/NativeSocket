//
//  ViewController.m
//  NativeSocket
//
//  Created by wangliang on 2018/1/2.
//  Copyright © 2018年 wangliang. All rights reserved.
//

#import "ViewController.h"
#import "SocketManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *msgTextField;

@property(nonatomic,strong) SocketManager *socketMgr;

@end

@implementation ViewController


- (IBAction)connectButton:(id)sender {
    
    [self.socketMgr connect];
}

- (IBAction)sendMsg:(id)sender {
    
    [self.socketMgr sendMessage:self.msgTextField.text];
}

- (IBAction)disConnetButton:(id)sender {
    
    [self.socketMgr disConnect];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
   _socketMgr=[SocketManager shareManager];
    
}

//客户端
//1. 创建socket
//2. 调用connect向服务器发起连接请求
//3. 客户端与服务器建立连接后,通过send() 或 receive() 向客户端发送数据 或从客户端接受数据
//4. 客户端调用close 关闭socket


//服务器端
//1. 服务器调用socket() 创建socket
//2. 服务器调用listen（） 设置缓冲区
//3. 服务器通过accept() 接受客户端请求建立连接
//4. 服务器与客户端建立连接后,通过send() 或 receive() 向客户端发送数据 或从客户端接受数据
//5. 服务器调用close关闭socket


@end

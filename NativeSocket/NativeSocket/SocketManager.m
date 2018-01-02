//
//  SocketManager.m
//  NativeSocket
//
//  Created by wangliang on 2018/1/2.
//  Copyright © 2018年 wangliang. All rights reserved.
//

#import "SocketManager.h"
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface SocketManager()

@property(nonatomic,assign) int clientSocket;

@end

@implementation SocketManager

+(instancetype)shareManager
{
    static SocketManager *instance=nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance=[[self alloc] init];
        
        [instance initSocket];
        
        [instance pullMessage];
    });
    
    return instance;
}

//build connect
-(void)connect
{
    [self initSocket];
}

//send message
-(void)sendMessage:(NSString *)msg
{
    const char *send_Message=[msg UTF8String];
    
    send(self.clientSocket, send_Message, strlen(send_Message)+1, 0);
}

//cancel connect
-(void)disConnect
{ 
    close(self.clientSocket);
}

#pragma mark -- new thread receive message
-(void)pullMessage
{
    NSThread *thread=[[NSThread alloc] initWithTarget:self selector:@selector(receiveMsg) object:nil];
    
    [thread start];
}

//get server message
-(void)receiveMsg
{
    while (1) {
        
        char receive_Msg[1024]={0};
        
        recv(self.clientSocket, receive_Msg, sizeof(receive_Msg), 0);
        
        printf("%s\n",receive_Msg);
    }
}

-(void)initSocket
{
    if (_clientSocket != 0)
    {
        [self disConnect];
        
        _clientSocket=0;
    }
    
    //create client socket
    _clientSocket=socket(AF_INET, SOCK_STREAM, 0);
    
    const char *server_ip="127.0.0.1";
    
    short server_port=1358;
    //count=0 represent connect fail
    int count=connectionToServer(_clientSocket, server_ip, server_port);
    
    if (count == 0)
    {
        printf("connect to server fail \n");
        return;
    }
    
    printf("connet to server success");
}

static int connectionToServer(int client_socket,const char *server_ip,unsigned short port)
{
    /*
     struct sockaddr_in {
         __uint8_t    sin_len;
         sa_family_t    sin_family;
         in_port_t    sin_port;
         struct    in_addr sin_addr;
         char        sin_zero[8];
     };
     */
    struct sockaddr_in sAddr={0};
    
    sAddr.sin_len=sizeof(sAddr);
    
    //setup Ipv4
    sAddr.sin_family=AF_INET;
    
    //convert string IP address to network senquence,return count is not nil mean to address is right
    inet_aton(server_ip, &sAddr.sin_addr);
    
    sAddr.sin_port=htons(port);
    
    //0 represent connect request success / or -1 fail
    int count=connect(client_socket, (struct sockaddr *)&sAddr, sizeof(sAddr));
    if (count == 0)
    {
        return client_socket;
    }
    
    return 0;
}

@end

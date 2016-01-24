//
//  LTCRXMPPTool.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/22.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRXMPPTool.h"
#import "LTCRUserInfo.h"


@interface LTCRXMPPTool () <XMPPStreamDelegate>{
    LTCRXMPPResultBlock _resultBlock;
}

@end
@implementation LTCRXMPPTool
singleton_implementation(LTCRXMPPTool)

//设置XMPPStream
- (void) setupXMPPStream {
    self.xmppStream = [[XMPPStream alloc] init];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
//连接到服务器
- (void) connectToServer {
    /** 断开上一次连接 */
    [self.xmppStream disconnect];
    
    if (self.xmppStream == nil) {
        [self setupXMPPStream];
    }
    self.xmppStream.hostName = LTCRXMPPHOSTNAME;
    self.xmppStream.hostPort = LTCRXMPPPORT;
    //构建一个JID
    NSString *userName = nil;
    /** 注册和登陆的区别是， 登陆的时候用登陆名，注册的时候用注册名，其他连接服务器的代码都相同*/
    if ([LTCRUserInfo sharedLTCRUserInfo].isRegisterType) {
        userName = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
        
    }else {
        userName = [LTCRUserInfo sharedLTCRUserInfo].userName;
    }
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",userName,LTCRXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.xmppStream.myJID = jid;
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        MYLog(@"连接错误:%@",error.userInfo);
    }
}
///发送密码登陆和注册
- (void) sendPassword {
    NSError *error = nil;
    NSString *userPassword = nil;
    if ([LTCRUserInfo sharedLTCRUserInfo].isRegisterType) {
        userPassword = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
        if (![self.xmppStream registerWithPassword:userPassword error:&error]) {
            MYLog(@"发送密码错误:%@",error.userInfo);
        }
    }else {
        userPassword = [LTCRUserInfo sharedLTCRUserInfo].userPassword;
        [self.xmppStream authenticateWithPassword:userPassword error:&error];
        if (error) {
            MYLog(@"发送错误:%@",error.userInfo);
        }
    }
}
//发送在线消息给服务器
- (void) sendOnLine {
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}
#pragma mark - XMPPStreamDelegate
- (void) xmppStreamDidConnect:(XMPPStream *)sender {
    [self sendPassword];
}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    if (error) {
        if (error && _resultBlock) {
            _resultBlock(LTCRXMPPResultTypeNetDeeor);
        }
        MYLog(@"断开连接:%@",error.userInfo);
    }
}
- (void) xmppStreamDidAuthenticate:(XMPPStream *)sender {
    _resultBlock(LTCRXMPPResultTypeLoginSuccess);
    [self sendOnLine];
}
- (void) xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    _resultBlock(LTCRXMPPResultTypeLoginFailed);
    MYLog(@"授权失败:%@",error);
}
///用户注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    _resultBlock(LTCRXMPPResultTypeRegisterSuccess);
}
///用户注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    _resultBlock(LTCRXMPPResultTypeRegisterFailed);
}
#pragma mark - 登陆和注册的响应
///用户登陆
- (void)userLogin:(LTCRXMPPResultBlock)block {
    _resultBlock = block;
    [self connectToServer];
}
///用户注册
- (void)userRegister:(LTCRXMPPResultBlock)block {
    _resultBlock = block;
    [self connectToServer];
}
@end

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
    userName = [LTCRUserInfo sharedLTCRUserInfo].userName;
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",userName,LTCRXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.xmppStream.myJID = jid;
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"连接错误:%@",error.userInfo);
    }
}
//发送密码 请求授权
- (void) sendPassword {
    NSError *error = nil;
    [self.xmppStream authenticateWithPassword:[LTCRUserInfo sharedLTCRUserInfo].userPassword error:&error];
    if (error) {
        NSLog(@"发送错误:%@",error.userInfo);
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
        NSLog(@"断开连接:%@",error.userInfo);
    }
}
- (void) xmppStreamDidAuthenticate:(XMPPStream *)sender {
    _resultBlock(LTCRXMPPResultTypeLoginSuccess);
    [self sendOnLine];
}
- (void) xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    _resultBlock(LTCRXMPPResultTypeLoginFailed);
    NSLog(@"授权失败:%@",error);
}
- (void)userLogin:(LTCRXMPPResultBlock)block {
    _resultBlock = block;
    [self connectToServer];
}
@end

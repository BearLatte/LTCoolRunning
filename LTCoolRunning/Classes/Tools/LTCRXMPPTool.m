//
//  LTCRXMPPTool.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/22.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRXMPPTool.h"
#import "LTCRUserInfo.h"
#import "AFNetworking.h"
#import "NSString+LTCRNMd5.h"

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
    ///初始化电子名片模块和头像模块
    self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStorage];
    self.xmppvCardAvar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCard];
    //激活名片模块和头像模块
    [self.xmppvCard activate:self.xmppStream];
    [self.xmppvCardAvar activate:self.xmppStream];
    
    //初始化花名册模块和头像
    self.xmppRosterStore = [[XMPPRosterCoreDataStorage alloc] init];
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStore];
    //激活花名册模块和头像
    [self.xmppRoster activate:self.xmppStream];
}
//连接到服务器
- (void) connectToServer {
    
    if (!self.xmppStream) {
        [self setupXMPPStream];
    }
    self.xmppStream.hostName = LTCRXMPPHOSTNAME;
    self.xmppStream.hostPort = LTCRXMPPPORT;
    //构建一个JID
    NSString *userName = [LTCRUserInfo sharedLTCRUserInfo].userName;
    /** 注册和登陆的区别是， 登陆的时候用登陆名，注册的时候用注册名，其他连接服务器的代码都相同*/
    if ([LTCRUserInfo sharedLTCRUserInfo].registerType) {
        userName = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
    }
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",userName,LTCRXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.xmppStream.myJID = jid;
    MYLog(@"MYJID:%@",self.xmppStream.myJID);
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
    if ([LTCRUserInfo sharedLTCRUserInfo].registerType) {
        userPassword = [LTCRUserInfo sharedLTCRUserInfo].userRegisterPassword;
        [self.xmppStream registerWithPassword:userPassword error:&error];
    }else {
        userPassword = [LTCRUserInfo sharedLTCRUserInfo].userPassword;
        [self.xmppStream authenticateWithPassword:userPassword error:&error];
    }
    MYLog(@"密码:%@",userPassword);
    if (error) {
        MYLog(@"发送密码错误:%@",error.userInfo);
    }
}
//发送在线消息给服务器
- (void) sendOnLine {
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}
/** 退出时发送离线消息 */
- (void) sendOffLine
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
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
    MYLog(@"myJID:%@",sender.myJID);
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
    /** 断开上一次连接 */
    [self.xmppStream disconnect];
    
    
    [self connectToServer];
}
///用户注册
- (void)userRegister:(LTCRXMPPResultBlock)block {
    _resultBlock = block;
    /** 断开上一次连接 */
    [self.xmppStream disconnect];
    
    [self connectToServer];
}
//释放资源
- (void) dealloc {
    //移除代理
    [_xmppStream removeDelegate:self];
    //停止激活
}
/** 完成web注册请求的方法 */
- (void)webRegiseterForServer {
    //实现web请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/register.jsp",LTCRXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
    parameters[@"md5password"] = [[LTCRUserInfo sharedLTCRUserInfo].userRegisterPassword md5StrXor];
    MYLog(@"MD5串:%@",parameters[@"md5password"]);
    parameters[@"nickname"] = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *image = [UIImage imageNamed:@"icon"];
        NSData *data = UIImagePNGRepresentation(image);
        [formData appendPartWithFileData:data name:@"pic" fileName:@"headerImage.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"headerImage.png%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"error:%@",error.userInfo);
    }];
}
@end

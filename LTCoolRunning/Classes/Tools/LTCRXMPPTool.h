//
//  LTCRXMPPTool.h
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/22.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
//#import "XMPPMessageArchiving_Contact_CoreDataObject.h"
//#import "XMPPMessageArchiving_Message_CoreDataObject.h"

typedef enum {
    LTCRXMPPResultTypeLoginSuccess,
    LTCRXMPPResultTypeLoginFailed,
    LTCRXMPPResultTypeNetDeeor,
    LTCRXMPPResultTypeRegisterSuccess,
    LTCRXMPPResultTypeRegisterFailed
}LTCRXMPPResultType;

/** 定义block进行传值 */
typedef void(^LTCRXMPPResultBlock)(LTCRXMPPResultType type);

@interface LTCRXMPPTool : NSObject
singleton_interface(LTCRXMPPTool)

@property (nonatomic, strong) XMPPStream *xmppStream;
/** 增加电子名片模块和头像模块 */
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvar;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCard;
/** 管理电子名片模块 */
@property (nonatomic, strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
///花名册模块
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStore;
///增加消息模块 和对应的存储
@property (nonatomic, strong) XMPPMessageArchiving *xmppArchiving;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageCoreData;
/** 用户登录 哪里需要XMPP的登录状态就传一个block进来即可*/
- (void) userLogin:(LTCRXMPPResultBlock)block;

///用户注册 哪里需要XMPP的注册状态就传一个Block进来即可
- (void) userRegister:(LTCRXMPPResultBlock)block;
/** 完成web注册请求的方法 */
- (void)webRegiseterForServer;
@end
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

typedef enum {
    LTCRXMPPResultTypeLoginSuccess,
    LTCRXMPPResultTypeLoginFailed,
    LTCRXMPPResultTypeNetDeeor
}LTCRXMPPResultType;

/** 定义block进行传值*/
typedef void(^LTCRXMPPResultBlock)(LTCRXMPPResultType type);

@interface LTCRXMPPTool : NSObject
singleton_interface(LTCRXMPPTool)

@property (nonatomic, strong) XMPPStream *xmppStream;
/** 用户登录 哪里需要XMPP的登录状态就传一个block进来即可*/
- (void) userLogin:(LTCRXMPPResultBlock)block;

@end
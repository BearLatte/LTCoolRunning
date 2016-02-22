//
//  LTCRUserInfo.h
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/22.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface LTCRUserInfo : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, strong) NSString *jidStr;
singleton_interface(LTCRUserInfo);

@property (nonatomic, strong) NSString *userRegisterName;
@property (nonatomic, strong) NSString *userRegisterPassword;
///区分到底是登陆还是注册
@property (nonatomic, assign, getter=isRegisterType) BOOL registerType;
///区分是不是新浪注册和登陆
@property (nonatomic, assign) BOOL sinaLoginAndRegister;
@property (nonatomic, strong) NSString *sinaToken;

///获取当前用户jidStr
- (NSString *)jidStr;

/* 用户数据的沙盒读写 */
- (void) saveKRUserInfoToSandBox;
- (void) loadKRUserInfoFromSandBox;
@end

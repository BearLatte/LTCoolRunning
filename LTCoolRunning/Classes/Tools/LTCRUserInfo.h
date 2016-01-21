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
singleton_interface(LTCRUserInfo);
@end

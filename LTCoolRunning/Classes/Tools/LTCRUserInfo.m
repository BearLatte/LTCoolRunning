//
//  LTCRUserInfo.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/22.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRUserInfo.h"

@implementation LTCRUserInfo
singleton_implementation(LTCRUserInfo)
- (NSString *)jidStr {
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",self.userName,LTCRXMPPDOMAIN];
    return jidStr;
}
@end

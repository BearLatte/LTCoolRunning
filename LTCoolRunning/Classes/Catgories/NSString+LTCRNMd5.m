//
//  NSString+LTCRNMd5.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/24.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "NSString+LTCRNMd5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LTCRNMd5)
- (NSString *)md5StrXor {
    const char *password = [self UTF8String];
    unsigned char md5c[CC_MD5_DIGEST_LENGTH];
    CC_MD5(password, (CC_LONG)StrLength(password), md5c);
    NSMutableString *md5Str = [NSMutableString string];
    [md5Str appendFormat:@"%02x",md5c[0]];
    for (int i = 1; i < 16; i++) {
        [md5Str appendFormat:@"%02x",md5c[i]^md5c[0]];
    }
    return [md5Str copy];
}
@end
//
//  AppDelegate.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/21.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "AppDelegate.h"




@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setNavigationBarStyle];
    return YES;
}
//设置导航栏的统一样式
- (void)setNavigationBarStyle {
    //设置导航栏背景
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBackgroundImage:[UIImage imageNamed:@"矩形"] forBarMetrics:UIBarMetricsDefault];
    bar.barStyle = UIBarStyleBlack;
    bar.tintColor = [UIColor whiteColor];
}
@end
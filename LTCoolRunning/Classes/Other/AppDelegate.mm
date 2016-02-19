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
    self.manager = [[BMKMapManager alloc] init];
    [self.manager start:@"Z6t3qs3UQ8ET2bldI9oAGdLX" generalDelegate:self];
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
#pragma mark - 百度地图第三方库的协议方法
//网络状态
- (void)onGetNetworkState:(int)iError {
    if (iError == 0) {
        MYLog(@"联网成功");
    }else {
        MYLog(@"onGetNetworkState:%d",iError);
    }
}
//授权状态
- (void)onGetPermissionState:(int)iError {
    if (iError == 0) {
        MYLog(@"授权成功");
    }else {
        MYLog(@"授权失败:%d",iError);
    }
}
@end
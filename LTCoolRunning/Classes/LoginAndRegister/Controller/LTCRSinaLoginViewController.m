//
//  LTCRSinaLoginViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/24.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRSinaLoginViewController.h"
#import "AFNetworking.h"
#import "LTCRUserInfo.h"
#import "LTCRXMPPTool.h"
#import "MBProgressHUD+KR.h"
#define APPKEY          @"1001724701"
#define APPSECRET       @"807565e637558982fd008f6a9fe8f9ca"
#define REDIRECT_URI    @"http://www.sina.com"

@interface LTCRSinaLoginViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
@implementation LTCRSinaLoginViewController
#pragma mark - 视图控制器的生命周期
- (void)viewDidLoad {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@",APPKEY,REDIRECT_URI]];
    self.webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}
#pragma mark - 界面上按钮的响应方法
- (IBAction)backToLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlPath = request.URL.absoluteString;
    MYLog(@"urlPath:%@",urlPath);
    NSRange range = [urlPath rangeOfString:[NSString stringWithFormat:@"%@%@",REDIRECT_URI,@"/?code="]];
    NSString *code = nil;
    if (range.length > 0) {
        code = [urlPath substringFromIndex:range.length];
        MYLog(@"code = %@",code);
        //使用code换取access_token
        [self accessTokenWithCode:code];
        return NO;
    }
    return YES;
}
//使用code换取 access_token
- (void)accessTokenWithCode:(NSString *)code {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = @"https://api.weibo.com/oauth2/access_token";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"client_id"]        = APPKEY;
    parameters[@"client_secret"]    = APPSECRET;
    parameters[@"grant_type"]       = @"authorization_code";
    parameters[@"code"]             = code;
    parameters[@"redirect_uri"]     = REDIRECT_URI;
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"请求成功，返回值:%@",responseObject);
        //用返回值uid作为账号的一部分，用返回值access_token作为密码发起注册
        [LTCRUserInfo sharedLTCRUserInfo].userRegisterName      = [NSString stringWithFormat:@"sina_%@",responseObject[@"uid"]];
        [LTCRUserInfo sharedLTCRUserInfo].userRegisterPassword  = responseObject[@"access_token"];
        [LTCRUserInfo sharedLTCRUserInfo].sinaToken = responseObject[@"access_token"];
        [LTCRUserInfo sharedLTCRUserInfo].registerType = YES;
        __weak typeof(self) weakSefl = self;
        [[LTCRXMPPTool sharedLTCRXMPPTool] userRegister:^(LTCRXMPPResultType type) {
            //处理返回type
            [weakSefl handleRegisterResult:type];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"请求错误:%@",error.userInfo);
    }];
}
//处理注册状态
- (void)handleRegisterResult:(LTCRXMPPResultType)type {
    switch (type) {
        case LTCRXMPPResultTypeRegisterSuccess:
            [LTCRUserInfo sharedLTCRUserInfo].sinaLoginAndRegister = NO;
            [LTCRUserInfo sharedLTCRUserInfo].registerType = NO;
            [[LTCRXMPPTool sharedLTCRXMPPTool] webRegiseterForServer];
        case LTCRXMPPResultTypeRegisterFailed: {
            [LTCRUserInfo sharedLTCRUserInfo].userName = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
            [LTCRUserInfo sharedLTCRUserInfo].userPassword = [LTCRUserInfo sharedLTCRUserInfo].userRegisterPassword;
            [[LTCRXMPPTool sharedLTCRXMPPTool] userLogin:^(LTCRXMPPResultType type) {
                [self handleLoginResult:type];
            }];
            break;
        }
        case LTCRXMPPResultTypeNetDeeor:
            [MBProgressHUD showError:@"网络错误"];
            break;
        default:
            break;
    }
}
//处理登陆状态
- (void)handleLoginResult:(LTCRXMPPResultType)type {
    switch (type) {
        case LTCRXMPPResultTypeLoginSuccess: {
            [MBProgressHUD showSuccess:@"登陆成功"];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
            break;
        }
        default:
            break;
    }
}
@end
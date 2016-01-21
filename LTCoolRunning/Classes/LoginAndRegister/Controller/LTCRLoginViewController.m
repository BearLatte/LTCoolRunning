//
//  LTCRLoginViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/21.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRLoginViewController.h"
#import "AppDelegate.h"
#import "LTCRUserInfo.h"
#import "LTCRXMPPTool.h"
#import "LTCRRegisterViewController.h"

@interface LTCRLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswordTextField;

@end

@implementation LTCRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *userNameLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    userNameLeftView.contentMode = UIViewContentModeCenter;
    userNameLeftView.frame = CGRectMake(0, 0, 55, 20);
    self.userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.userNameTextField.leftView = userNameLeftView;
    UIImageView *userPasswordLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
    userPasswordLeftView.frame = CGRectMake(0, 0, 55, 20);
    userPasswordLeftView.contentMode = UIViewContentModeCenter;
    self.userPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.userPasswordTextField.leftView = userPasswordLeftView;
}
- (IBAction)clickButtonLogin:(id)sender {
    /** 点击按钮把输入框中的值赋值给全局单例对象 */
    LTCRUserInfo *userInfo = [LTCRUserInfo sharedLTCRUserInfo];
    userInfo.userName = self.userNameTextField.text;
    userInfo.userPassword = self.userPasswordTextField.text;
    LTCRXMPPTool *xmppTool = [LTCRXMPPTool sharedLTCRXMPPTool];
    //登录并返回登录状态
    __weak typeof (self) weakSelf = self;
    [xmppTool userLogin:^(LTCRXMPPResultType type) {
        //处理返回状态
        [weakSelf handleXMPPResult:type];
    }];
}
/** 处理登录返回状态的方法 */
- (void)handleXMPPResult:(LTCRXMPPResultType)type {
    switch (type) {
        case LTCRXMPPResultTypeLoginSuccess: {
            NSLog(@"登录成功");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
            break;
        }
        case LTCRXMPPResultTypeLoginFailed:
            NSLog(@"登录失败");
            break;
        case LTCRXMPPResultTypeNetDeeor:
            NSLog(@"网络错误");
            break;
        default:
            break;
    }
}
- (void)dealloc {
    NSLog(@"%@",self);
}
@end

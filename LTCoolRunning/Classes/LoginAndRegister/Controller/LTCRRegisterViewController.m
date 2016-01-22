//
//  LTCRRegisterViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/22.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRRegisterViewController.h"
#import "LTCRXMPPTool.h"
#import "LTCRUserInfo.h"

@interface LTCRRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *registerUserNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *registerUserPasswordTextField;

@end

@implementation LTCRRegisterViewController
#pragma mark - 视图控制器的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *userNameLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    userNameLeftView.contentMode = UIViewContentModeCenter;
    userNameLeftView.frame = CGRectMake(0, 0, 55, 20);
    self.registerUserNameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.registerUserNameTextField.leftView = userNameLeftView;
    
    
    UIImageView *userPasswordLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
    userPasswordLeftView.contentMode = UIViewContentModeCenter;
    userPasswordLeftView.frame = CGRectMake(0, 0, 55, 20);
    self.registerUserPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.registerUserPasswordTextField.leftView = userPasswordLeftView;
}
- (void)dealloc {
    MYLog(@"%@",self);
}
#pragma mark - 按钮的响应方法
- (IBAction)clickButtonRegister:(id)sender {
    [LTCRUserInfo sharedLTCRUserInfo].userRegisterName = self.registerUserNameTextField.text;
    [LTCRUserInfo sharedLTCRUserInfo].userRegisterPassword = self.registerUserPasswordTextField.text;
    [LTCRUserInfo sharedLTCRUserInfo].registerType = YES;
    ///调用userRegister方法完成注册
    __weak typeof(self) weakSelf = self;
    [[LTCRXMPPTool sharedLTCRXMPPTool] userRegister:^(LTCRXMPPResultType type) {
        [weakSelf handleXMPPResult:type];
    }];
}
- (IBAction)backToLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
///处理返回状态
- (void)handleXMPPResult:(LTCRXMPPResultType)type {
    switch (type) {
        case LTCRXMPPResultTypeRegisterSuccess: {
            MYLog(@"注册成功");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case LTCRXMPPResultTypeRegisterFailed:
            MYLog(@"注册失败");
            break;
        case LTCRXMPPResultTypeNetDeeor:
            MYLog(@"网络错误");
            break;
        default:
            break;
    }
}
@end

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
#import "MBProgressHUD+KR.h"
#import "AFNetworking.h"
#import "NSString+LTCRNMd5.h"

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
            [self webRegiseterForServer];
            //显示用户友好提示信息
            [MBProgressHUD showSuccess:@"注册成功"];
            [LTCRUserInfo sharedLTCRUserInfo].userName = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
            [LTCRUserInfo sharedLTCRUserInfo].userPassword = [LTCRUserInfo sharedLTCRUserInfo].userRegisterPassword;
            
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case LTCRXMPPResultTypeRegisterFailed:
            [MBProgressHUD showError:@"注册失败"];
            break;
        case LTCRXMPPResultTypeNetDeeor:
            [MBProgressHUD showError:@"网络错误"];
            break;
        default:
            break;
    }
}
/** 完成web注册请求的方法 */
- (void)webRegiseterForServer {
    //实现web请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/register.jsp",LTCRXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
    parameters[@"md5password"] = [[LTCRUserInfo sharedLTCRUserInfo].userRegisterPassword md5StrXor];
    MYLog(@"MD5串:%@",parameters[@"md5password"]);
    parameters[@"nickname"] = [LTCRUserInfo sharedLTCRUserInfo].userRegisterName;
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *image = [UIImage imageNamed:@"icon"];
        NSData *data = UIImagePNGRepresentation(image);
        [formData appendPartWithFileData:data name:@"pic" fileName:@"headerImage.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"headerImage.png%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"error:%@",error.userInfo);
    }];
}
@end

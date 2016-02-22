//
//  LTCRMyProfileViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/26.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRMyProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "LTCRXMPPTool.h"
#import "LTCRUserInfo.h"
#import "LTCREditMyProfileViewController.h"
#import "UIImageView+LTCRImageView.h"

@interface LTCRMyProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNickNameLabel;

@end

@implementation LTCRMyProfileViewController
#pragma mark - 视图控制器的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    XMPPvCardTemp *vCordTemp = [LTCRXMPPTool sharedLTCRXMPPTool].xmppvCard.myvCardTemp;
    self.userNickNameLabel.text = vCordTemp.nickname;
    self.userNameLabel.text = [LTCRUserInfo sharedLTCRUserInfo].userName;
    if (!vCordTemp.photo) {
        self.headerImageView.image = [UIImage imageNamed:@"微信"];
    }else {
        self.headerImageView.image = [UIImage imageWithData:vCordTemp.photo];
    }
    [self.headerImageView setImageView];
}
#pragma mark - 视图上按钮的响应方法
- (IBAction)backMainController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = segue.destinationViewController;
    if ([[navigationController topViewController] isKindOfClass:[LTCREditMyProfileViewController class]]) {
        LTCREditMyProfileViewController *editMyProfileController = (LTCREditMyProfileViewController *)[navigationController topViewController];
        editMyProfileController.vCard = [LTCRXMPPTool sharedLTCRXMPPTool].xmppvCard.myvCardTemp;
    }
}
- (IBAction)logOut:(id)sender {
    [[LTCRUserInfo sharedLTCRUserInfo] saveKRUserInfoToSandBox];
    [[LTCRXMPPTool sharedLTCRXMPPTool] sendOffLine];
    [LTCRUserInfo sharedLTCRUserInfo].jidStr = nil;
    if ([LTCRUserInfo sharedLTCRUserInfo].sinaLoginAndRegister) {
        [LTCRUserInfo sharedLTCRUserInfo].sinaLoginAndRegister = NO;
        [LTCRUserInfo sharedLTCRUserInfo].userName = nil;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
    UIViewController *vc = storyboard.instantiateInitialViewController;
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}
@end

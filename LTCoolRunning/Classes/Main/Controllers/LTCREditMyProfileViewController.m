//
//  LTCREditMyProfileViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/26.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCREditMyProfileViewController.h"
#import "LTCRXMPPTool.h"
#import "UIImageView+LTCRImageView.h"

@interface LTCREditMyProfileViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UITextField *userNikeTextField;
@property (weak, nonatomic) IBOutlet UITextField *userEmailTextField;

@end

@implementation LTCREditMyProfileViewController
#pragma mark - 视图控制器的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.vCard.photo) {
        self.headerImageView.image = [UIImage imageWithData:self.vCard.photo];
    }else {
        self.headerImageView.image = [UIImage imageNamed:@"Placeholder"];
    }
    self.userNikeTextField.text = self.vCard.nickname;
    self.userEmailTextField.text = self.vCard.mailer;
    [self.headerImageView setImageView];
    self.headerImageView.userInteractionEnabled = YES;
    //增加手势识别
    [self.headerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageTap)]];
}
//图片tap方法的处理
- (void)headerImageTap {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择图片" message:@"请选择您要选择照片的路径" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camearaAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerCameraCaptureModeVideo;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }else {
            MYLog(@"进入系统相机");
        }
    }];
    UIAlertAction *photoAlbumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.allowsEditing = YES;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.delegate = self;
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:photoAlbumAction];
    [alertController addAction:camearaAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 视图按钮的响应方法
- (IBAction)updateMyProfile:(id)sender {
    //得到用户输入的数据 头像 昵称 邮件 更新
    self.vCard.photo = UIImagePNGRepresentation(self.headerImageView.image);
    self.vCard.nickname = self.userNikeTextField.text;
    self.vCard.mailer = self.userEmailTextField.text;
    
    [[LTCRXMPPTool sharedLTCRXMPPTool].xmppvCard updateMyvCardTemp:self.vCard];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clickButtonItemCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
//选择图片的处理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headerImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

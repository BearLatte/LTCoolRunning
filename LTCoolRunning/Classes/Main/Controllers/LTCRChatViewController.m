 //
//  LTCRChatViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/27.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRChatViewController.h"
#import "LTCRXMPPTool.h"
#import "LTCRUserInfo.h"
#import "LTCRMeCell.h"
#import "LTCROtherCell.h"
#import "UIImageView+LTCRImageView.h"

@interface LTCRChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hightForBottom;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@end

@implementation LTCRChatViewController
#pragma mark - 视图控制器的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.contactJID user];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //设置cell自适应高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    [self loadMessage];
    [self scrollToTableViewLastRow];
    UITapGestureRecognizer *tapRG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCloseKeyboard)];
    [self.tableView addGestureRecognizer:tapRG];
}
//点击tableView收回键盘
- (void)clickCloseKeyboard {
    [self.sendMessageTextField resignFirstResponder];
}
- (void)loadMessage {
    //获取上下文对象
    NSManagedObjectContext *objectContext = [[LTCRXMPPTool sharedLTCRXMPPTool].xmppMessageCoreData mainThreadManagedObjectContext];
    //关联实体
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //设置条件和过滤 设置当前用户和好友的jidStr
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@",[LTCRUserInfo sharedLTCRUserInfo].jidStr,[self.contactJID bare]];
    request.predicate = predicate;
    //排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[descriptor];
    //结果执行
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:objectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.resultsController.delegate = self;
    NSError *error = nil;
    [self.resultsController performFetch:&error];
    
    if (error) {
        MYLog(@"获取结果错误:%@",error.userInfo);
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //视图控制器即将显示的时候增加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //视图控制器即将消失的时候注销键盘通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - 键盘通知的响应方法
- (void)openKeyboard:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval durations = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    self.hightForBottom.constant = keyboardFrame.size.height;
    [UIView animateWithDuration:durations delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    [self scrollToTableViewLastRow];
}
- (void)closeKeyboard:(NSNotification *)notification {
    NSTimeInterval durations = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    self.hightForBottom.constant = 0;
    [UIView animateWithDuration:durations delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    [self scrollToTableViewLastRow];
}
- (void)scrollToTableViewLastRow {
    if (self.resultsController.fetchedObjects.count != 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.resultsController.fetchedObjects.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
#pragma mark - 发送文本消息的响应方法
- (IBAction)sendMessageTextMethod:(id)sender {
    NSString *messageText = self.sendMessageTextField.text;
    //组装一个消息
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.contactJID];
    [message addBody:messageText];
    [[LTCRXMPPTool sharedLTCRXMPPTool].xmppStream sendElement:message];
    self.sendMessageTextField.text = nil;
    [self.sendMessageTextField resignFirstResponder];
}
- (IBAction)sendMessage:(id)sender {
    [self sendMessageTextMethod:nil];
}
- (IBAction)sendImageButtonClick:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerCameraCaptureModeVideo;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }else {
            MYLog(@"进入系统相机");
        }
    }];
    UIAlertAction *photoLabraryAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        //imagePickerController.editing = YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cameraAction];
    [alertController addAction:photoLabraryAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - NSFetched Results Controller Delegate
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    
//}
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    
//}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //[self.tableView endUpdates];
    [self.tableView reloadData];
}
#pragma mark - UITable View Data Source And UITable View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsController.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *messageObject = self.resultsController.fetchedObjects[indexPath.row];
    if (messageObject.isOutgoing) {
        LTCRMeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meCell"];
        [self configMeCell:cell withIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        LTCROtherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
        [self configOtherCell:cell withIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}
///设置meCell
- (void)configMeCell:(LTCRMeCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *messageObject = self.resultsController.fetchedObjects[indexPath.row];
    NSData *photo = [[LTCRXMPPTool sharedLTCRXMPPTool].xmppvCardAvar photoDataForJID:[XMPPJID jidWithString:[LTCRUserInfo sharedLTCRUserInfo].jidStr]];
    if (!photo) {
        cell.headerImageView.image = [UIImage imageNamed:@"Placeholder"];
    }else {
        cell.headerImageView.image = [UIImage imageWithData:photo];
    }
    [cell.headerImageView setImageView];
    cell.userNameLabel.text = [LTCRUserInfo sharedLTCRUserInfo].userName;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm:ss"];
    cell.messageTimeLabel.text = [formatter stringFromDate:messageObject.timestamp];
    //判断是图片消息还是文字消息
    if ([messageObject.body hasPrefix:@"image:"]) {
        NSString *base64Str = [messageObject.body substringFromIndex:6];
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
        cell.messageImageView.image = [UIImage imageWithData:imageData];
    }else {
        cell.messageContentLabel.text = messageObject.body;
    }
}
///设置otherCell
- (void)configOtherCell:(LTCROtherCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *messageObject = self.resultsController.fetchedObjects[indexPath.row];
    NSData *photo = [[LTCRXMPPTool sharedLTCRXMPPTool].xmppvCardAvar photoDataForJID:[XMPPJID jidWithString:messageObject.bareJidStr]];
    if (!photo) {
        cell.headerImageView.image = [UIImage imageNamed:@"Placeholder"];
    }else {
        cell.headerImageView.image = [UIImage imageWithData:photo];
    }
    [cell.headerImageView setImageView];
    cell.userNameLabel.text = [self.contactJID user];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm:ss"];
    cell.messageTimeLabel.text = [formatter stringFromDate:messageObject.timestamp];
    if ([messageObject.body hasPrefix:@"image:"]) {
        NSString *base64Str = [messageObject.body substringFromIndex:6];
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
        cell.messageImageView.image = [UIImage imageWithData:imageData];
    }else {
         cell.messageContentLabel.text = messageObject.body;
    }
}
#pragma mark - UIImage Picker Controller Delegate,UINavigation Controller Delegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    MYLog(@"image length:%ld",UIImagePNGRepresentation(image).length);
    //生成缩略图片
    UIImage *newImage = [self thumbnaiWithImage:image size:CGSizeMake(100, 100)];
    MYLog(@"newImage length:%ld",UIImagePNGRepresentation(newImage).length);
    MYLog(@"newImage2 length:%ld",UIImageJPEGRepresentation(newImage, 0.2).length);
    //把图片包装成消息发送出去
    [self sendImageMethodWithImage:newImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//发送图片消息的方法
- (void)sendImageMethodWithImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.2);
    NSString *base64Str = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.contactJID];
    [message addBody:[@"image:" stringByAppendingString:base64Str]];
    [[LTCRXMPPTool sharedLTCRXMPPTool].xmppStream sendElement:message];
}
//生成缩略图的方法
- (UIImage *)thumbnaiWithImage:(UIImage *)image size:(CGSize)size {
    UIImage *newImage = nil;
    if (nil == image) {
        newImage = nil;
    }else {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;
}
@end
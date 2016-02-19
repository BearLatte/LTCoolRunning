//
//  LTCRLastMessageViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/30.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRLastMessageViewController.h"
#import "LTCRXMPPTool.h"
#import "LTCRUserInfo.h"
#import "UIImageView+LTCRImageView.h"
#import "LTCRContactCell.h"
#import "LTCRChatViewController.h"

@interface LTCRLastMessageViewController ()
//声明一个数组，存放最后的信息
@property (nonatomic, strong) NSArray *lastMessageArray;
@end

@implementation LTCRLastMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    XMPPMessageArchiving_Contact_CoreDataObject
    [self loadLastMessage];
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = footerView;
}
//加载聊天的最后一条信息
- (void)loadLastMessage {
    //获取上下文对象
    NSManagedObjectContext *objectContext = [[LTCRXMPPTool sharedLTCRXMPPTool].xmppMessageCoreData mainThreadManagedObjectContext];
    //关联实体
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
    //设置条件和过滤 设置当前用户和好友的jidStr
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[LTCRUserInfo sharedLTCRUserInfo].jidStr];
    request.predicate = predicate;
    //排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:YES];
    request.sortDescriptors = @[descriptor];
    //结果执行
    NSError *error = nil;
    self.lastMessageArray = [objectContext executeFetchRequest:request error:&error];
    if (error) {
        MYLog(@"获取结果错误:%@",error.userInfo);
    }
}
- (IBAction)backToMyProfile:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lastMessageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lastCell"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"lastCell"];
//    }
    static NSString *identifier = @"lastMessageCell";
    LTCRContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    XMPPMessageArchiving_Contact_CoreDataObject *contactObject = self.lastMessageArray[indexPath.row];
    NSData *photo = [[LTCRXMPPTool sharedLTCRXMPPTool].xmppvCardAvar photoDataForJID:contactObject.bareJid];
    if (!photo) {
        cell.headerImageView.image = [UIImage imageNamed:@"Placeholder"];
    }else {
        cell.headerImageView.image = [UIImage imageWithData:photo];
    }
    [cell.headerImageView setImageView];
//    [cell.imageView setImageView];
    cell.messageBodyLabel.text = contactObject.mostRecentMessageBody;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm:ss"];
    cell.messageTimeLabel.text = [formatter stringFromDate:contactObject.mostRecentMessageTimestamp];
    //cell.textLabel.text = messageObject.mostRecentMessageBody;
    NSString *userName = contactObject.bareJidStr;
    NSRange range = NSMakeRange(0, userName.length - 10);
    cell.userNameLabel.text = [userName substringWithRange:range];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.lastMessageArray[indexPath.row];
    [self performSegueWithIdentifier:@"lastChatSegue" sender:contact.bareJid];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destinationViewController = segue.destinationViewController;
    if ([destinationViewController isKindOfClass:[LTCRChatViewController class]]) {
        LTCRChatViewController *targetViewController = (LTCRChatViewController *)destinationViewController;
        targetViewController.contactJID = sender;
    }
}
@end

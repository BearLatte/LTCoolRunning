//
//  LTCRContactTableViewController.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/26.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "LTCRContactTableViewController.h"
#import "LTCRContactTableViewCell.h"
#import "LTCRXMPPTool.h"
#import "UIImageView+LTCRImageView.h"
#import "LTCRUserInfo.h"
#import <CoreData/CoreData.h>
#import "LTCRChatViewController.h"
#import "MBProgressHUD+KR.h"

@interface LTCRContactTableViewController () <NSFetchedResultsControllerDelegate,UIAlertViewDelegate>
//@property (nonatomic, strong) NSArray *contactsArray;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@end

@implementation LTCRContactTableViewController

#pragma mark - 视图控制器的生命周期以及加载视图响应的方法
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //加载好友
    [self loadContact];
    self.tableView.tableFooterView = [[UIView alloc] init];
}
//- (void)loadContact {
//    //获得上下文
//    NSManagedObjectContext *managedContext = [[LTCRXMPPTool sharedLTCRXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
//    //关联实体NSFetchRequest
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
//    //设置过滤条件
//    request.predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and subscription != %@",[LTCRUserInfo sharedLTCRUserInfo].jidStr,@"none"];
//    //设置排序
//    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]];
//    //提取数据
//    NSError *error = nil;
//    self.contactsArray = [managedContext executeFetchRequest:request error:&error];
//    if (error) {
//        MYLog(@"读取数据错误:%@",error.userInfo);
//    }
//}
//
//  v2 Version
- (void)loadContact {
    //获得上下文
    NSManagedObjectContext *managedContext = [[LTCRXMPPTool sharedLTCRXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
    //关联实体NSFetchRequest
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //设置过滤条件
    request.predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and subscription != %@",[LTCRUserInfo sharedLTCRUserInfo].jidStr,@"none"];
    //设置排序
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]];
    //提取数据
    NSError *error = nil;
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedContext sectionNameKeyPath:nil cacheName:nil];
    self.resultsController.delegate = self;
    [self.resultsController performFetch:&error];
    if (error) {
        MYLog(@"读取数据错误:%@",error.userInfo);
    }
}

#pragma mark - 按钮的响应方法
- (IBAction)clickButtonBackMainController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clickButtonItemAddContact:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加好友" message:@"输入好友用户名" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
//    [self presentViewController:alertView animated:YES completion:nil];
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"请输入好友用户名" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *enterAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    [alertController addAction:enterAction];
//    [alertController addAction:cancelAction];
//    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - UIAlert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            MYLog(@"000000000");
            break;
        case 1:
            MYLog(@"%@",[alertView textFieldAtIndex:0].text);
            [self addContactWithUserName:[alertView textFieldAtIndex:0].text];
            break;
            
        default:
            break;
    }
}
- (void)addContactWithUserName:(NSString *)userName {
    if (userName.length > 0) {
        XMPPJID *contactJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",userName,LTCRXMPPDOMAIN]];
        [[LTCRXMPPTool sharedLTCRXMPPTool].xmppRoster subscribePresenceToUser:contactJID];
    }else {
        [MBProgressHUD showError:@"用户名不能为空"];
        return;
    }
}
#pragma mark - NSFechedResultsControllerDelegate
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
#pragma mark - Table view data source And Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    return self.contactsArray.count;
    return self.resultsController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    LTCRContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    XMPPUserCoreDataStorageObject *contact = self.contactsArray[indexPath.row];
    XMPPUserCoreDataStorageObject *contact = self.resultsController.fetchedObjects[indexPath.row];
    NSData *data = [[LTCRXMPPTool sharedLTCRXMPPTool].xmppvCardAvar photoDataForJID:[contact jid]];
    if (data) {
        cell.headerImageView.image = [UIImage imageWithData:data];
    }else {
        cell.headerImageView.image = [UIImage imageNamed:@"Placeholder"];
    }
    [cell.headerImageView setImageView];
    cell.contactNameLabel.text = contact.jidStr;
    //用状态码获取用户登录状态 0：登录 1：离开 2：离线
    switch (contact.sectionNum.intValue) {
        case 0:
            cell.contactStatusLabel.text = @"在线";
            cell.contactStatusLabel.textColor = [UIColor greenColor];
            break;
        case 1:
            cell.contactStatusLabel.text = @"离开";
            cell.contactStatusLabel.textColor = [UIColor blackColor];
        case 2:
            cell.contactStatusLabel.text = @"离线";
            cell.contactStatusLabel.textColor = [UIColor grayColor];
        default:
            break;
    }
    
    return cell;
}
//选中某一行实现跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPUserCoreDataStorageObject *contact = self.resultsController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"chatSegue" sender:contact.jid];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destinationViewController = segue.destinationViewController;
    if ([destinationViewController isKindOfClass:[LTCRChatViewController class]]) {
        LTCRChatViewController *targetViewController = (LTCRChatViewController *)destinationViewController;
        targetViewController.contactJID = sender;
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPUserCoreDataStorageObject *contactObject = self.resultsController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[LTCRXMPPTool sharedLTCRXMPPTool].xmppRoster removeUser:contactObject.jid];
    }
}

@end

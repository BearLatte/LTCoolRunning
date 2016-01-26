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

@interface LTCRContactTableViewController () <NSFetchedResultsControllerDelegate>
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
}
- (IBAction)clickButtonBackMainController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
#pragma mark - NSFechedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}
#pragma mark - Table view data source

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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPUserCoreDataStorageObject *contactObject = self.resultsController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[LTCRXMPPTool sharedLTCRXMPPTool].xmppRoster removeUser:contactObject.jid];
    }
}

@end

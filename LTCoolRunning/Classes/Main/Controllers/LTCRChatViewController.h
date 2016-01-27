//
//  LTCRChatViewController.h
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/27.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"

@interface LTCRChatViewController : UIViewController
@property (nonatomic, strong) XMPPJID *contactJID;
@end

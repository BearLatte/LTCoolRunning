//
//  LTCRMeCell.h
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/27.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTCRMeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;

@end

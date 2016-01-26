//
//  LTCRContactTableViewCell.h
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/26.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTCRContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactStatusLabel;

@end

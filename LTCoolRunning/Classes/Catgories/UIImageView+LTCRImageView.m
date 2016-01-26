//
//  UIImageView+LTCRImageView.m
//  LTCoolRunning
//
//  Created by Latte_Bear on 16/1/26.
//  Copyright © 2016年 Latte_Bear. All rights reserved.
//

#import "UIImageView+LTCRImageView.h"

@implementation UIImageView (LTCRImageView)
- (void)setImageView {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.height * 0.5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
}
@end

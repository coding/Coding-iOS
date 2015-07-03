//
//  OTPTableViewCell.h
//  Coding_iOS
//
//  Created by Ease on 15/7/3.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTPAuthURL.h"

@interface OTPTableViewCell : UITableViewCell
@property (strong, nonatomic) OTPAuthURL *authURL;
+ (CGFloat)cellHeight;
@end

@interface TOTPTableViewCell : OTPTableViewCell
//@property (strong, nonatomic) TOTPAuthURL *curAuthURL;
@end

@interface HOTPTableViewCell : OTPTableViewCell
//@property (strong, nonatomic) HOTPAuthURL *curAuthURL;
@end


//
//  PRMRSearchCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/24.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRPR.h"

@interface PRMRSearchCell : UITableViewCell
@property (strong, nonatomic) MRPR *curMRPR;

+ (CGFloat)cellHeightWithObj:(id)obj;
@end

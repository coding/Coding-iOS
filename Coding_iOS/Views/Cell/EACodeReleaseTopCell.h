//
//  EACodeReleaseTopCell.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/23.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EACodeRelease.h"

@interface EACodeReleaseTopCell : UITableViewCell
@property (strong, nonatomic) EACodeRelease *curR;

@property (copy, nonatomic) void(^tagClickedBlock)(EACodeRelease *curR);

+ (CGFloat)cellHeightWithObj:(EACodeRelease *)obj;
@end

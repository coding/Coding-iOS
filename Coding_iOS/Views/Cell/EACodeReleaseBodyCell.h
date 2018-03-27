//
//  EACodeReleaseBodyCell.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/23.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EACodeRelease.h"

@interface EACodeReleaseBodyCell : UITableViewCell
@property (strong, nonatomic) EACodeRelease *curR;

@property (nonatomic, copy) void (^cellHeightChangedBlock)();
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);

+ (CGFloat)cellHeightWithObj:(EACodeRelease *)obj;
@end

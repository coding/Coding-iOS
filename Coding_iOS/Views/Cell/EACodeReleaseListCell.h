//
//  EACodeReleaseListCell.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EACodeRelease.h"
#import "SWTableViewCell.h"

@interface EACodeReleaseListCell : SWTableViewCell
@property (strong, nonatomic) EACodeRelease *curCodeRelease;
@end

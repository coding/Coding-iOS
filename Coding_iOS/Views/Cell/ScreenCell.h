//
//  ScreenCell.h
//  Coding_iOS
//
//  Created by zhangdadi on 2016/12/14.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCellIdentifier_ScreenCell @"ScreenCell"

@interface ScreenCell : UITableViewCell
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) BOOL isSel;

@end

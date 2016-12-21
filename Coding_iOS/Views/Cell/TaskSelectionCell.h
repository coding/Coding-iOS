//
//  TaskSelectionCell.h
//  Coding_iOS
//
//  Created by 张达棣 on 16/12/7.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCellIdentifier_TaskSelectionCell @"TaskSelectionCell"

@interface TaskSelectionCell : UITableViewCell
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isSel;
@property (nonatomic, assign) BOOL isShowLine;
@property (nonatomic, strong) UIImageView *selImageView;

@end

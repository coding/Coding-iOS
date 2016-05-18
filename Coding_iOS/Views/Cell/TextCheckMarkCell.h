//
//  TextCheckMarkCell.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_TextCheckMarkCell @"TextCheckMarkCell"

#import <UIKit/UIKit.h>

@interface TextCheckMarkCell : UITableViewCell
@property (strong, nonatomic) NSString *textStr;
@property (assign, nonatomic) BOOL checked;
+ (CGFloat)cellHeight;

@end

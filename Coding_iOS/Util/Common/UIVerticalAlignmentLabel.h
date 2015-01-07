//
//  UIVerticalAlignmentLabel.h
//  Coding_iOS
//
//  Created by Ease on 15/1/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface UIVerticalAlignmentLabel : UILabel
@property (nonatomic) VerticalAlignment verticalAlignment;

@end

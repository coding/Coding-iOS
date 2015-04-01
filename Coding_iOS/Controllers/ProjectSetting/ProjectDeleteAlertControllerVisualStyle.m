//
//  ProjectDeleteAlertControllerVisualStyle.m
//  Coding_iOS
//
//  Created by isaced on 15/4/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectDeleteAlertControllerVisualStyle.h"

@implementation ProjectDeleteAlertControllerVisualStyle

-(UIColor *)titleLabelColor{
    return [UIColor colorWithRGBHex:0x222222];
}

-(UIColor *)messageLabelColor{
    return [UIColor colorWithRGBHex:0xf34a4a];
}

- (CGFloat)labelSpacing {
    return 30;
}

- (CGFloat)messageLabelBottomSpacing {
    return 20;
}

@end

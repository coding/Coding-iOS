//
//  ScanBGView.m
//  Coding_iOS
//
//  Created by Ease on 15/7/6.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ScanBGView.h"

@implementation ScanBGView
- (void)setBackgroundColor:(UIColor *)backgroundColor{
    super.backgroundColor = backgroundColor;
    [self setNeedsDisplay];
}

- (void)setScanRect:(CGRect)scanRect{
    _scanRect = scanRect;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, rect);
    
    [self.backgroundColor setFill];
    CGRect topRect = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetMinY(_scanRect));
    CGRect bottomRect = CGRectMake(0, CGRectGetMaxY(_scanRect), CGRectGetWidth(bounds), CGRectGetHeight(bounds) - CGRectGetMaxY(_scanRect));
    CGRect leftRect = CGRectMake(0, CGRectGetMinY(_scanRect), CGRectGetMinX(_scanRect), CGRectGetHeight(_scanRect));
    CGRect rightRect = CGRectMake(CGRectGetMaxX(_scanRect), CGRectGetMinY(_scanRect), CGRectGetWidth(bounds) - CGRectGetMaxX(_scanRect), CGRectGetHeight(_scanRect));
    
    CGContextAddRect(context, topRect);
    CGContextAddRect(context, bottomRect);
    CGContextAddRect(context, leftRect);
    CGContextAddRect(context, rightRect);
    
    CGContextFillPath(context);
}
@end

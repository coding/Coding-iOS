//
//  DashesLineView.m
//  BanTang
//
//  Created by liaoyp on 15/10/16.
//  Copyright © 2015年 JiuZhouYunDong. All rights reserved.
//

#import "DashesLineView.h"

@implementation DashesLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    CGContextSetLineWidth(context, 1);
    
    CGContextSetStrokeColorWithColor(context,  _lineColor.CGColor);
    
    CGFloat lengths[] = {2,2};
    
    CGContextSetLineDash(context, 0, lengths, 2);
    
    CGContextMoveToPoint(context, 0, 0);
    
    CGContextAddLineToPoint(context, CGRectGetWidth(rect), 0);
    
    CGContextStrokePath(context);
    
    CGContextClosePath(context);

}

@end

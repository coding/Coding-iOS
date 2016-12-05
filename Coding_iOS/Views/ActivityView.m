//
//  ActivityView.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/29.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "ActivityView.h"

@interface ActivityView ()
@property (nonatomic, strong) NSArray *typeColorArray;
@end

@implementation ActivityView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatView];
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self creatView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
     CGContextRef ctx = UIGraphicsGetCurrentContext();

    for (int i = 0; i < _colorArray.count; ++i) {
        NSInteger line = i /7;
        NSInteger row = i % 7;
        CGContextAddRect(ctx, CGRectMake(line * 11, row * 11, 10, 10));
        UIColor *color = _colorArray[i];
        [color set];
        CGContextFillPath(ctx);
    }
    
}

- (void)creatView {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setColorArray:(NSArray<UIColor *> *)colorArray {
    _colorArray = colorArray;
    [self setNeedsDisplay];
    
    
}

@end

//
//  UITableView+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UITableView+Common.h"

@implementation UITableView (Common)

- (void)addRadiusforCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 5.f;
        
        cell.backgroundColor = UIColor.clearColor;
        
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        CGRect bounds = CGRectInset(cell.bounds, 0, 0);
        
        BOOL addLine = NO;
        
        if (indexPath.row == 0 && indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
            
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            
        } else if (indexPath.row == 0) {
            
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            
            addLine = YES;
            
        } else if (indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
            
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            
        } else {
            
            CGPathAddRect(pathRef, nil, bounds);
            
            addLine = YES;
            
        }
        
        layer.path = pathRef;
        
        CFRelease(pathRef);
        
//        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
        if (cell.backgroundColor) {
            layer.fillColor = cell.backgroundColor.CGColor;//layer的填充色用cell原本的颜色
        }else if (cell.backgroundView && cell.backgroundView.backgroundColor){
            layer.fillColor = cell.backgroundView.backgroundColor.CGColor;
        }else{
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
        }
        
        if (addLine == YES) {
            
            CALayer *lineLayer = [[CALayer alloc] init];
            
            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
            
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+2, bounds.size.height-lineHeight, bounds.size.width-2, lineHeight);
            
            lineLayer.backgroundColor = self.separatorColor.CGColor;
            
            [layer addSublayer:lineLayer];
            
        }
        
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        
        [testView.layer insertSublayer:layer atIndex:0];
        
        testView.backgroundColor = UIColor.clearColor;
        
        cell.backgroundView = testView;
    }
}

- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpaceAndSectionLine:(CGFloat)leftSpace{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGRect bounds = CGRectInset(cell.bounds, 0, 0);
    
    CGPathAddRect(pathRef, nil, bounds);
    
    layer.path = pathRef;
    
    CFRelease(pathRef);
    if (cell.backgroundColor) {
        layer.fillColor = cell.backgroundColor.CGColor;//layer的填充色用cell原本的颜色
    }else if (cell.backgroundView && cell.backgroundView.backgroundColor){
        layer.fillColor = cell.backgroundView.backgroundColor.CGColor;
    }else{
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
    }
    CGColorRef lineColor = kColorDDD.CGColor;

    //判断整个tableview 最后的元素
    if ((self.numberOfSections==(indexPath.section+1))&&indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
        //上短,下长
//        [self layer:layer addLineUp:TRUE andLong:YES andColor:lineColor andBounds:bounds withLeftSpace:leftSpace];
        [self layer:layer addLineUp:NO andLong:YES andColor:lineColor andBounds:bounds withLeftSpace:0];
    }else
    {
        [self layer:layer addLineUp:NO andLong:NO andColor:lineColor andBounds:bounds withLeftSpace:leftSpace];
    }
    
    UIView *testView = [[UIView alloc] initWithFrame:bounds];
    [testView.layer insertSublayer:layer atIndex:0];
    cell.backgroundView = testView;

}

- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpace:(CGFloat)leftSpace hasSectionLine:(BOOL)hasSectionLine{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGRect bounds = CGRectInset(cell.bounds, 0, 0);
    
    CGPathAddRect(pathRef, nil, bounds);
    
    layer.path = pathRef;
    
    CFRelease(pathRef);
    if (cell.backgroundColor) {
        layer.fillColor = cell.backgroundColor.CGColor;//layer的填充色用cell原本的颜色
    }else if (cell.backgroundView && cell.backgroundView.backgroundColor){
        layer.fillColor = cell.backgroundView.backgroundColor.CGColor;
    }else{
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
    }
    
    CGColorRef lineColor = kColorD8DDE4.CGColor;
    CGColorRef sectionLineColor = lineColor;
    
    if (indexPath.row == 0 && indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
        //只有一个cell。加上长线&下长线
        if (hasSectionLine) {
            [self layer:layer addLineUp:YES andLong:YES andColor:sectionLineColor andBounds:bounds withLeftSpace:0];
            [self layer:layer addLineUp:NO andLong:YES andColor:sectionLineColor andBounds:bounds withLeftSpace:0];
        }
    } else if (indexPath.row == 0) {
        //第一个cell。加上长线&下短线
        if (hasSectionLine) {
            [self layer:layer addLineUp:YES andLong:YES andColor:sectionLineColor andBounds:bounds withLeftSpace:0];
        }
        [self layer:layer addLineUp:NO andLong:NO andColor:lineColor andBounds:bounds withLeftSpace:leftSpace];
    } else if (indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
        //最后一个cell。加下长线
        if (hasSectionLine) {
            [self layer:layer addLineUp:NO andLong:YES andColor:sectionLineColor andBounds:bounds withLeftSpace:0];
        }
    } else {
        //中间的cell。只加下短线
        [self layer:layer addLineUp:NO andLong:NO andColor:lineColor andBounds:bounds withLeftSpace:leftSpace];
    }
    UIView *testView = [[UIView alloc] initWithFrame:bounds];
    [testView.layer insertSublayer:layer atIndex:0];
    cell.backgroundView = testView;
}
- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpace:(CGFloat)leftSpace{
    [self addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:leftSpace hasSectionLine:YES];
}

- (void)layer:(CALayer *)layer addLineUp:(BOOL)isUp andLong:(BOOL)isLong andColor:(CGColorRef)color andBounds:(CGRect)bounds withLeftSpace:(CGFloat)leftSpace{
    
    CALayer *lineLayer = [[CALayer alloc] init];
    CGFloat lineHeight = (1.0f / [UIScreen mainScreen].scale);
    CGFloat left, top;
    if (isUp) {
        top = 0;
    }else{
        top = bounds.size.height-lineHeight;
    }
    
    if (isLong) {
        left = 0;
    }else{
        left = leftSpace;
    }
    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+left, top, bounds.size.width-left, lineHeight);
    lineLayer.backgroundColor = color;
    [layer addSublayer:lineLayer];
}

- (UITapImageView *)getHeaderViewWithStr:(NSString *)headerStr andBlock:(void(^)(id obj))tapAction{
    return [self getHeaderViewWithStr:headerStr color:kColorTableSectionBg andBlock:tapAction];
}

- (UITapImageView *)getHeaderViewWithStr:(NSString *)headerStr color:(UIColor *)color andBlock:(void(^)(id obj))tapAction{
    UITapImageView *headerView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width,30)];
    [headerView setImage:[UIImage imageWithColor:color]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreen_Width-20, CGRectGetHeight(headerView.frame))];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = kColor999;
    if (kDevice_Is_iPhone6Plus) {
        headerLabel.font = [UIFont systemFontOfSize:14];
    }else{
        headerLabel.font = [UIFont systemFontOfSize:kScaleFrom_iPhone5_Desgin(12)];
    }
    headerLabel.text = headerStr;
    [headerView addSubview:headerLabel];
    [headerView addTapBlock:tapAction];
    return headerView;
}

- (UITapImageView *)getHeaderViewWithStr:(NSString *)headerStr color:(UIColor *)color leftNoticeColor:(UIColor*)noticeColor andBlock:(void(^)(id obj))tapAction{
    UITapImageView *headerView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width,44)];
    [headerView setImage:[UIImage imageWithColor:color]];
    
    UIView* noticeView=[[UIView alloc] initWithFrame:CGRectMake(12, 14, 3, 16)];
    noticeView.backgroundColor=noticeColor;
    [headerView addSubview:noticeView];

    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12+3+10, 7, kScreen_Width-20, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = kColor999;
    if (kDevice_Is_iPhone6Plus) {
        headerLabel.font = [UIFont systemFontOfSize:14];
    }else{
        headerLabel.font = [UIFont systemFontOfSize:kScaleFrom_iPhone5_Desgin(12)];
    }
    
    CGFloat lineHeight = (1.0f / [UIScreen mainScreen].scale);
    UIView *seperatorline = [[UIView alloc] initWithFrame:CGRectMake(0, 44-lineHeight,kScreen_Width , lineHeight)];
    seperatorline.backgroundColor = kColorDDD;
    [headerView addSubview:seperatorline];
    
    headerLabel.text = headerStr;
    [headerView addSubview:headerLabel];
    [headerView addTapBlock:tapAction];
    return headerView;

}
@end

//
//  AutoSlideScrollView.h
//  AutoSlideScrollViewDemo
//
//  Created by Mike Chen on 14-1-23.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoSlideScrollView : UIView

@property (nonatomic , readonly) UIScrollView *scrollView;
@property (nonatomic , assign, readonly) NSInteger currentPageIndex;

/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;

- (void)reloadData;

/**
 数据源：获取总的page个数，如果少于2个，不自动滚动
 **/
@property (nonatomic , copy) NSInteger (^totalPagesCount)();

/**
 数据源：获取第pageIndex个位置的contentView
 **/
@property (nonatomic , copy) UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);

/**
 当点击的时候，执行的block
 **/
@property (nonatomic , copy) void (^tapActionBlock)(NSInteger pageIndex);

/**
 当currentPageIndex改变的时候，执行的block
 **/
@property (nonatomic , copy) void (^currentPageIndexChangeBlock)(NSInteger currentPageIndex);

@end
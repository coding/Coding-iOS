//
//  EaseToolBar.h
//  Coding_iOS
//
//  Created by Ease on 14/11/27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PPiAwesomeButton/UIAwesomeButton.h>

@class EaseToolBar;

@protocol EaseToolBarDelegate <NSObject>
@optional
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index;
@end

@interface EaseToolBar : UIView
@property (nonatomic, weak) id <EaseToolBarDelegate> delegate;

+ (instancetype)easeToolBarWithItems:(NSArray *)buttonItems;
- (id)itemOfIndex:(NSInteger)index;
- (instancetype)initWithItems:(NSArray *)buttonItems;

@end

@interface EaseToolBarItem : UIAwesomeButton
+ (instancetype)easeToolBarItemWithTitle:(NSString *)title image:(NSString *)imageName disableImage:(NSString *)disableImageName;
- (instancetype)initWithTitle:(NSString *)title image:(NSString *)imageName disableImage:(NSString *)disableImageName;
- (void)addTipIcon;
- (void)removeTipIcon;
@end
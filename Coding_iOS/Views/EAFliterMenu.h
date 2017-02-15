//
//  EAFliterMenu.h
//  Coding_iOS
//
//  Created by Ease on 2017/2/15.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EAFliterMenu : UIView
@property (strong, nonatomic) NSArray *items;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, copy) void (^clickBlock)(NSInteger selectIndex);
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;
- (void)showMenuInView:(UIView *)containerView;
- (void)dismissMenu;
@end

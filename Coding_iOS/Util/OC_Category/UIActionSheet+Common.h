//
//  UIActionSheet+Common.h
//  Coding_iOS
//
//  Created by Ease on 15/1/14.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (Common)
+ (instancetype)bk_actionSheetCustomWithTitle:(NSString *)title buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIActionSheet *sheet, NSInteger index))block;

@end

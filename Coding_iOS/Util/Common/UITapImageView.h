//
//  UITapImageView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-7.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITapImageView : UIImageView
- (void)addTapBlock:(void(^)(id obj))tapAction;

-(void)setImageWithUrl:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage tapBlock:(void(^)(id obj))tapAction;
@end

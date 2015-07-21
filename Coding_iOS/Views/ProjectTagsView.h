//
//  ProjectTagsView.h
//  Coding_iOS
//
//  Created by Ease on 15/7/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+PressMenu.h"
#import "ProjectTag.h"

@interface ProjectTagsView : UIView
@property (strong, nonatomic) NSArray *tags;
@property (nonatomic, copy) void (^deleteTagBlock)(ProjectTag *tag);
@property (nonatomic, copy) void (^addTagBlock)();

- (instancetype)initWithTags:(NSArray *)tags;
+ (instancetype)viewWithTags:(NSArray *)tags;
+ (CGFloat)getHeightForTags:(NSArray *)tags;
@end

@interface ProjectTagsViewLabel : UILabel
@property (strong, nonatomic) ProjectTag *curTag;
@property (nonatomic, copy) void (^deleteBlock)(ProjectTag *tag);
+ (instancetype)labelWithTag:(ProjectTag *)tag andDeleteBlock:(void (^)(ProjectTag *tag))block;
@end



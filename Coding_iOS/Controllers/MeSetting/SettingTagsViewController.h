//
//  SettingTagsViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingTagsViewController : BaseViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) NSArray *allTags;
@property (strong, nonatomic) NSMutableArray *selectedTags;
@property (copy, nonatomic) void(^doneBlock)(NSArray *selectedTags);

+ (instancetype)settingTagsVCWithAllTags:(NSArray *)allTags selectedTags:(NSArray *)selectedTags doneBlock:(void(^)(NSArray *selectedTags))block;
@end

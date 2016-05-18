//
//  NewProjectTypeViewController.h
//  Coding_iOS
//
//  Created by isaced on 15/3/30.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NewProjectType) {
    NewProjectTypePrivate = 0,
    NewProjectTypePublic = 1,
};

@class NewProjectTypeViewController;

@protocol NewProjectTypeDelegate <NSObject>

// 选中回调
-(void)newProjectType:(NewProjectTypeViewController *)newProjectVC
        didSelectType:(NewProjectType)type;

@end

@interface NewProjectTypeViewController : UITableViewController

@property (nonatomic, assign) id<NewProjectTypeDelegate> delegate;

// 项目类型
@property (nonatomic, assign) NewProjectType projectType;

@end

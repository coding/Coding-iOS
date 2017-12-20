//
//  EaseGitButtonsView.h
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define EaseGitButtonsView_Height (56.0 + kSafeArea_Bottom)
#import "EaseGitButton.h"

#import <UIKit/UIKit.h>
#import "Project.h"

@interface EaseGitButtonsView : UIView

@property (strong, nonatomic) Project *curProject;
@property (copy, nonatomic) void(^gitButtonClickedBlock)(NSInteger index, EaseGitButtonPosition position);

@end

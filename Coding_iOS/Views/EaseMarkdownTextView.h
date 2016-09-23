//
//  EaseMarkdownTextView.h
//  Coding_iOS
//
//  Created by Ease on 15/2/9.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "Projects.h"

@interface EaseMarkdownTextView : UIPlaceHolderTextView<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) Project *curProject;
@property (assign, nonatomic) BOOL isForProjectTweet;
@end
